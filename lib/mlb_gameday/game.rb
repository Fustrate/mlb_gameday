module MLBGameday
	class Game
		def initialize(api, data)
			@api = api
			@data = data

			@home = @api.team(@data.xpath("//game/@home_name_abbrev").first.value)
			@away = @api.team(@data.xpath("//game/@away_name_abbrev").first.value)
		end

		def teams
			[@home, @away]
		end

		def home_team
			@home
		end

		def away_team
			@away
		end

		def venue
			@data.xpath("//game/@venue").first.value
		end

		def start_time(team = nil)
			team = @home if team.nil?

			return "#{ @data.xpath("//game/@away_time").first.value } #{ @data.xpath("//game/@away_time_zone").first.value }" if team == @away

			"#{ @data.xpath("//game/@home_time").first.value } #{ @data.xpath("//game/@home_time_zone").first.value }"
		end

		def status
			@data.xpath("//game/@status").first.value
		end

		def is_over?
			status.in? "Final"
		end
		alias_method :fat_lady_has_sung?, :is_over?

		def home_record
			[@data.xpath("//game/@home_win").first.value, @data.xpath("//game/@home_loss").first.value]
		end

		def away_record
			[@data.xpath("//game/@away_win").first.value, @data.xpath("//game/@away_loss").first.value]
		end

		def pitcher(team)
			if !is_over?





			end



			if team == @away
				# Probable pitchers before games, more difficult after
				if @data.xpath("//game/away_probable_pitcher").count > 0
					return @api.pitcher(@data.xpath("//game/away_probable_pitcher/@id").first.value,
						game_data: @data.xpath("//game/away_probable_pitcher").first)
				else
				end
			else
			end
		end
	end
end
