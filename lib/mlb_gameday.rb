require 'httparty'
require 'nokogiri'
require 'open-uri'
require 'yaml'

%w{version league division team game player pitcher batter}.each do |file|
  require "mlb_gameday/#{ file }"
end

module MLBGameday
  API_URL = 'http://gd2.mlb.com/components/game/mlb'

  class API
    attr_reader :leagues

    def initialize
      # File File File File File File File File File File File File File File File
      @leagues = YAML.load File.open(File.join(File.dirname(File.expand_path(__FILE__)), '../resources/data.yml'))
    end

    def league(name)
      return name if name.is_a? MLBGameday::League

      @leagues[name]
    end

    def team(name)
      return name if name.is_a? MLBGameday::Team

      teams.each do |team|
        return team if team.names.include? name.downcase
      end

      nil
    end

    def teams
      @teams ||= divisions.map(&:teams).map(&:values).flatten
    end

    def division(league, name)
      @leagues[league][name]
    end

    def divisions
      @divisions ||= @leagues[:AL].divisions.values + @leagues[:NL].divisions.values
    end

    def pitcher(id)
      return nil if id.empty?

      MLBGameday::Pitcher.new(self, id, fetch_pitcher_xml(id))
    end

    def batter(id)
      return nil if id.empty?

      MLBGameday::Batter.new(self, id, fetch_batter_xml(id))
    end

    def game(gid)
      MLBGameday::Game.new(
        self,
        gid,
        gamecenter: fetch_gamecenter_xml(gid),
        linescore: fetch_linescore_xml(gid),
        boxscore: fetch_boxscore_xml(gid)
      )
    end

    def find_games(team: nil, date: nil)
      date = Date.today if date.nil?

      doc = fetch_scoreboard_xml(date)

      if team.nil?
        doc.xpath('//games/game').map do |game|
          gid = game.xpath('@gameday_link').first.value

          MLBGameday::Game.new(
            self,
            gid,
            gamecenter: fetch_gamecenter_xml(gid),
            linescore: fetch_linescore_xml(gid),
            boxscore: fetch_boxscore_xml(gid)
          )
        end
      else
        team = team(team)

        doc.xpath('//games/game').map do |game|
          if [game.xpath('@home_name_abbrev').first.value, game.xpath('@away_name_abbrev').first.value].include? team.code
            gid = game.xpath('@gameday_link').first.value

            MLBGameday::Game.new(
              self,
              gid,
              gamecenter: fetch_gamecenter_xml(gid),
              linescore: fetch_linescore_xml(gid),
              boxscore: fetch_boxscore_xml(gid),
            )
          end
        end.compact!
      end
    end

    def fetch_scoreboard_xml(date)
      Nokogiri::XML(open(API_URL + date.strftime('/year_%Y/month_%m/day_%d/miniscoreboard.xml')))
    end

    def fetch_linescore_xml(gid)
      year, month, day, _ = gid.split('_')

      Nokogiri::XML(open(API_URL + "/year_#{ year }/month_#{ month }/day_#{ day }/gid_#{ gid }/linescore.xml"))
    end

    def fetch_boxscore_xml(gid)
      year, month, day, _ = gid.split('_')

      Nokogiri::XML(open(API_URL + "/year_#{ year }/month_#{ month }/day_#{ day }/gid_#{ gid }/boxscore.xml"))
    rescue
      nil
    end

    def fetch_gamecenter_xml(gid)
      year, month, day, _ = gid.split('_')

      Nokogiri::XML(open(API_URL + "/year_#{ year }/month_#{ month }/day_#{ day }/gid_#{ gid }/gamecenter.xml"))
    rescue
      nil
    end

    def fetch_batter_xml(id, year: nil)
      year = Date.today.year if year.nil?

      # We only really want one piece of data from this file...
      year_data = Nokogiri::XML(open(API_URL + "/year_#{ year }/batters/#{ id }.xml"))

      gid = year_data.xpath('//batting/@game_id').first.value
      year, month, day, _ = gid.split('/')

      Nokogiri::XML(open(MLBGameday::API_URL + "/year_#{ year }/month_#{ month }/day_#{ day }/gid_#{ gid.gsub(/[^a-z0-9]/, "_") }/batters/#{ id }.xml"))
    end

    def fetch_pitcher_xml(id, year: nil)
      year = Date.today.year if year.nil?

      # We only really want one piece of data from this file...
      year_data = Nokogiri::XML(open(API_URL + "/year_#{ year }/pitchers/#{ id }.xml"))

      gid = year_data.xpath('//pitching/@game_id').first.value
      year, month, day, _ = gid.split('/')

      Nokogiri::XML(open(MLBGameday::API_URL + "/year_#{ year }/month_#{ month }/day_#{ day }/gid_#{ gid.gsub(/[^a-z0-9]/, "_") }/pitchers/#{ id }.xml"))
    end
  end
end
