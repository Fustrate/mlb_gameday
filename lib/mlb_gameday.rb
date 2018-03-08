# frozen_string_literal: true

require 'httparty'
require 'nokogiri'
require 'open-uri'
require 'psych'
require 'chronic'

%w[version league division team game player pitcher batter].each do |file|
  require "mlb_gameday/#{file}"
end

module MLBGameday
  API_URL = 'http://gdx.mlb.com/components/game/mlb'

  BATTER = '/year_%<year>d/batters/%<id>d'
  PITCHER = '/year_%<year>d/pitchers/%<id>d'
  GAME_FOLDER = '/year_%<year>d/month_%02<month>d/day_%02<day>d/gid_%<gid>s'
  SCOREBOARD = '/year_%Y/month_%m/day_%d/miniscoreboard'

  class API
    attr_reader :leagues

    def initialize
      @data = Psych.load File.open File.join(
        File.dirname(File.expand_path(__FILE__)), '../resources/data.yml'
      )

      @leagues = @data[:leagues]
    end

    def league(name)
      return name if name.is_a? MLBGameday::League

      @leagues[name]
    end

    def team(name)
      return name if name.is_a? MLBGameday::Team

      teams.find { |team| team.called?(name) }
    end

    def teams
      @teams ||= divisions.map(&:teams).map(&:values).flatten +
                 miscellaneous_teams
    end

    def miscellaneous_teams
      @data[:miscellaneous_teams].values
    end

    def division(league, name)
      @leagues[league][name]
    end

    def divisions
      @divisions ||= @leagues[:AL].divisions.values +
                     @leagues[:NL].divisions.values
    end

    def pitcher(id, year: nil, gid: nil)
      return if id.empty?

      MLBGameday::Pitcher.new id: id, xml: pitcher_xml(id, year: year, gid: gid)
    end

    def batter(id, year: nil, gid: nil)
      return if id.empty?

      MLBGameday::Batter.new id: id, xml: batter_xml(id, year: year, gid: gid)
    end

    def game(gid)
      MLBGameday::Game.new(
        self,
        gid,
        gamecenter: gamecenter_xml(gid),
        linescore: linescore_xml(gid),
        rawboxscore: rawboxscore_xml(gid)
      )
    end

    def find_games(team: nil, date: nil)
      doc = scoreboard_xml(date || Date.today)

      if team
        code = team(team).code

        doc.xpath('//games/game').map do |game|
          next unless [game.xpath('@home_name_abbrev').text,
                       game.xpath('@away_name_abbrev').text].include? code

          game game.xpath('@gameday_link').text
        end.compact!
      else
        doc.xpath('//games/game').map do |game|
          game game.xpath('@gameday_link').to_s
        end
      end
    end

    def scoreboard_xml(date)
      fetch_xml date.strftime SCOREBOARD
    end

    def linescore_xml(gid)
      fetch_xml "#{GAME_FOLDER}/linescore", gid: gid
    end

    def rawboxscore_xml(gid)
      fetch_xml "#{GAME_FOLDER}/rawboxscore", gid: gid
    end

    def gamecenter_xml(gid)
      fetch_xml "#{GAME_FOLDER}/gamecenter", gid: gid
    end

    def batter_xml(id, year: nil, gid: nil)
      # We only really want one piece of data from this file. This gives us
      # the GID of their most recent appearance.
      gid ||= fetch_xml(BATTER, id: id, year: (year || Date.today.year))
        .xpath('//batting/@game_id').text.gsub(/[^a-z0-9]/, '_')

      fetch_xml "#{GAME_FOLDER}/batters/%<batter>s", gid: gid, batter: id
    end

    def pitcher_xml(id, year: nil, gid: nil)
      # We only really want one piece of data from this file. This gives us
      # the GID of their most recent appearance.
      gid ||= fetch_xml(PITCHER, id: id, year: (year || Date.today.year))
        .xpath('//pitching/@game_id').text.gsub(/[^a-z0-9]/, '_')

      fetch_xml "#{GAME_FOLDER}/pitchers/%<pitcher>s", gid: gid, pitcher: id
    end

    protected

    def fetch_xml(path, interpolations = {})
      full_path = "#{API_URL}#{path}.xml"

      if interpolations[:gid]
        year, month, day, = interpolations[:gid].split '_'

        interpolations[:year] = year
        interpolations[:month] = month
        interpolations[:day] = day
      end

      full_path = format(full_path, interpolations) if interpolations.any?

      Nokogiri::XML open full_path
    rescue
      nil
    end
  end
end
