module MLBGameday
	class Pitcher
		def initialize(api, data, game_data = nil)
			@api = api
			@data = data
			@game_data = game_data
		end

		def name
			game_data

		def era
			@data.xpath("//pitching/@era").first.value
		end

		def wins
			@data.xpath("//pitching/@w").first.value
		end

		def losses
			@data.xpath("//pitching/@l").first.value
		end

		def innings
			@data.xpath("//pitching/@s_ip").first.value
		end

		def saves
			@data.xpath("//pitching/@sv").first.value
		end

		def whip
			@data.xpath("//pitching/@whip").first.value
		end

		def strikeouts
			@data.xpath("//pitching/@k").first.value
		end

		def walks
			@data.xpath("//pitching/@bb").first.value
		end

		private

		def game_data
			return @game_data if !@game_data.nil?

			game = @data.xpath("//pitching/@game_id").first.value
			year, month, day, _ = game.split("/")

			@game_data = Nokogiri::XML(open(MLBGameday::API_URL + "year_#{ year }/month_#{ month }/day_#{ day }/gid_#{ game.gsub(/[^a-z0-9]/, "_") }/linescore.xml"))
	end
end
