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

		# Preview, In Progress, Final
		def status
			@status ||= @data.xpath("//game/@status").first.value
		end

		# [3, Top/Middle/Bottom/End]
		def inning
			[@data.xpath("//game/@inning"), @data.xpath("//game/@inning_state")]
		end

		def runners
			first, second, third = [nil, nil, nil]

			[first, second, third]

		def over?
			status == "Final"
		end
		alias_method :fat_lady_has_sung?, :over?

		def in_progress?
			status == "In Progress"
		end

		def home_record
			[xpath("//game/@home_win"), xpath("//game/@home_loss")].map(&:to_i)
		end

		def away_record
			[xpath("//game/@away_win"), xpath("//game/@away_loss")].map(&:to_i)
		end

		def current_pitcher
			return nil if !in_progress?

			@api.pitcher xpath("//game/current_pitcher/@id")
		end

		def opposing_pitcher
			return nil if !in_progress?

			@api.pitcher xpath("//game/opposing_pitcher/@id")
		end

		def winning_pitcher
			return nil if !over?

			@api.pitcher xpath("//game/winning_pitcher/@id")
		end

		def losing_pitcher
			return nil if !over?

			@api.pitcher xpath("//game/losing_pitcher/@id")
		end

		def save_pitcher
			return nil if !over?

			@api.pitcher xpath("//game/save_pitcher/@id")
		end

		def score
			[xpath("//game/@home_team_runs").to_i, xpath("//game/@away_team_runs").to_i]
		end

		def pitcher(team)
			if status == "In Progress"
				# The xpath changes based on which half of the inning it is
				if xpath("//game/@top_inning") == "Y"
					if team == :away || team == @away
						current_pitcher
					else
						opposing_pitcher
					end
				else
					if team == :away || team == @away
						opposing_pitcher
					else
						current_pitcher
					end
				end
			elsif status == "Preview"
				if team == :away || team == @away
					@api.pitcher xpath("//game/away_probable_pitcher/@id")
				else
					@api.pitcher xpath("//game/home_probable_pitcher/@id")
				end
			elsif status == "Final"
				home, away = score

				if home > away
					if team == :away || team == @away
						losing_pitcher
					else
						winning_pitcher
					end
				elsif away > home
					if team == :away || team == @away
						winning_pitcher
					else
						losing_pitcher
					end
				else
					# Spring training games can end in ties, in which case there's really no pitching data
					# See: http://gd2.mlb.com/components/game/mlb/year_2013/month_03/day_07/gid_2013_03_07_texmlb_lanmlb_1/linescore.xml
					nil
				end
			end
		end

		private

		def xpath(path)
			@data.xpath(path).first.value
		end
	end
end
