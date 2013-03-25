require 'httparty'
require 'nokogiri'
require 'open-uri'
require 'yaml'
require 'json'

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

		def pitcher(id, game_data: nil)
			MLBGameday::Pitcher.new(self, fetch_pitcher_xml(id), game_data)
		end

		def find_games(team: nil, date: nil)
			date = Date.today if date.nil?

			doc = fetch_scoreboard_json(date)

			if team.nil?
				doc["data"]["games"].each { |game| MLBGameday::Game.new(self, fetch_gameday_xml(date, game["gameday_link"])) }
			else
				team = team(team)

				doc["data"]["games"]["game"].map do |game|
					if [game["home_name_abbrev"], game["away_name_abbrev"]].include? team.code
						MLBGameday::Game.new(self, fetch_gameday_xml(date, game["gameday_link"]))
					end
				end.compact!
			end
		end

		def fetch_scoreboard_json(date)
			JSON.load(open(API_URL + date.strftime("/year_%Y/month_%m/day_%d/miniscoreboard.json")))
		end

		def fetch_gameday_json(date, gameday_link)
			JSON.load(open(API_URL + date.strftime("/year_%Y/month_%m/day_%d/gid_#{ gameday_link }/linescore.json")))
		end

		def fetch_gameday_xml(date, gameday_link)
			Nokogiri::XML(open(API_URL + date.strftime("/year_%Y/month_%m/day_%d/gid_#{ gameday_link }/linescore.xml")))
		end

		def fetch_pitcher_xml(id, year: nil)
			year = Date.today.year if year.nil?

			Nokogiri::XML(open(API_URL + "/year_#{ year }/pitchers/#{ id }.xml"))
		end
	end
end
