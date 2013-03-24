require 'httparty'
require 'nokogiri'
require 'yaml'

module MLBGameday
	class API
		def initialize
			@leagues = YAML.load(File.open('./mlb_gameday/data.yml'))
		end

		def leagues
			@leagues
		end

		def league(name)
			@leagues[name]
		end

		def team(name)
		end

		def teams
		end

		def division(league, name)
			@leagues[league][name]
		end

		def divisions
			@leagues[:AL].divisions.values + @leagues[:NL].divisions.values
		end
	end
end
