require 'httparty'
require 'nokogiri'
require 'open-uri'
require 'yaml'
require 'net/http'
require 'uri'

%w{version league division team game player}.each do |file|
	require "mlb_gameday/#{file}"
end

module MLBGameday
	API_URL = "http://gd2.mlb.com/components/game/mlb"

	class API
		def initialize
			# File File File File File File File File File File File File File File File
			@leagues = YAML.load File.open(File.join(File.dirname(File.expand_path(__FILE__)), '../resources/data.yml'))
		end

		def leagues
			@leagues
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

			MLBGameday::Pitcher.new(self, fetch_pitcher_xml(id))
		end

		def batter(id)
			return nil if id.empty?

			MLBGameday::Batter.new(self, fetch_batter_xml(id))
		end

		def find_games(team: nil, date: nil)
			date = Date.today if date.nil?

			doc = fetch_scoreboard_xml(date)

			if team.nil?
				doc.xpath("//games/game").map do |game|
					MLBGameday::Game.new(self, fetch_gameday_xml(date, game.xpath("@gameday_link").first.value))
				end
			else
				team = team(team)

				doc.xpath("//games/game").map do |game|
					if [game.xpath("@home_name_abbrev").first.value, game.xpath("@away_name_abbrev").first.value].include? team.code
						MLBGameday::Game.new(self, fetch_gameday_xml(date, game.xpath("@gameday_link")))
					end
				end.compact!
			end
		end

		private

		def fetch_scoreboard_xml(date)
			Nokogiri::XML(open(API_URL + date.strftime("/year_%Y/month_%m/day_%d/miniscoreboard.xml")))
		end

		def fetch_gameday_xml(date, gameday_link)
			Nokogiri::XML(open(API_URL + date.strftime("/year_%Y/month_%m/day_%d/gid_#{ gameday_link }/linescore.xml")))
		end

		def fetch_pitcher_xml(id, year: nil)
			year = Date.today.year if year.nil?

			# We only really want one piece of data from this file...
			year_data = Nokogiri::XML(open(API_URL + "/year_#{ year }/pitchers/#{ id }.xml"))

			game = year_data.xpath("//pitching/@game_id").first.value
			year, month, day, _ = game.split("/")

			Nokogiri::XML(open(MLBGameday::API_URL + "year_#{ year }/month_#{ month }/day_#{ day }/gid_#{ game.gsub(/[^a-z0-9]/, "_") }/pitchers/#{ id }.xml"))
		end
	end
end
