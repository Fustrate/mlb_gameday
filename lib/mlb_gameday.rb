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
  API_URL = 'http://gd2.mlb.com/components/game/mlb'

  BATTER = '/year_%{year}/batters/%{id}'
  PITCHER = '/year_%{year}/pitchers/%{id}'
  RAWBOXSCORE = '/year_%{year}/month_%{month}/day_%{day}/gid_%{gid}/rawboxscore'
  GAMECENTER = '/year_%{year}/month_%{month}/day_%{day}/gid_%{gid}/gamecenter'
  LINESCORE = '/year_%{year}/month_%{month}/day_%{day}/gid_%{gid}/linescore'
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

    def pitcher(id, year: nil)
      return if id.empty?

      MLBGameday::Pitcher.new id: id, xml: pitcher_xml(id, year: year)
    end

    def batter(id, year: nil)
      return if id.empty?

      MLBGameday::Batter.new id: id, xml: batter_xml(id, year: year)
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
      year, month, day, = gid.split '_'

      fetch_xml LINESCORE, year: year, month: month, day: day, gid: gid
    end

    def rawboxscore_xml(gid)
      year, month, day, = gid.split '_'

      fetch_xml RAWBOXSCORE, year: year, month: month, day: day, gid: gid
    end

    def gamecenter_xml(gid)
      year, month, day, = gid.split '_'

      fetch_xml GAMECENTER, year: year, month: month, day: day, gid: gid
    end

    def batter_xml(id, year: nil)
      # We only really want one piece of data from this file...
      year_data = fetch_xml BATTER, id: id, year: (year || Date.today.year)

      gid = year_data.xpath('//batting/@game_id').text
      year, month, day, = gid.split '/'

      fetch_xml "/year_#{year}/month_#{month}/day_#{day}/" \
                "gid_#{gid.gsub(/[^a-z0-9]/, '_')}/batters/#{id}"
    end

    def pitcher_xml(id, year: nil)
      # We only really want one piece of data from this file...
      year_data = fetch_xml PITCHER, id: id, year: (year || Date.today.year)

      gid = year_data.xpath('//pitching/@game_id').text
      year, month, day, = gid.split '/'

      fetch_xml "/year_#{year}/month_#{month}/day_#{day}/" \
                "gid_#{gid.gsub(/[^a-z0-9]/, '_')}/pitchers/#{id}"
    end

    protected

    def fetch_xml(path, interpolations = {})
      full_path = "#{API_URL}#{path}.xml"

      full_path = format(full_path, interpolations) if interpolations.any?

      Nokogiri::XML open full_path
    rescue
      nil
    end
  end
end
