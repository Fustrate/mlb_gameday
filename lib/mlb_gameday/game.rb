module MLBGameday
	class Game
		def initialize(api, linescore: nil, gamecenter: nil)
			@api = api
			@linescore = linescore
			@gamecenter = gamecenter

			@home = @api.team(@linescore.xpath("//game/@home_name_abbrev").first.value)
			@away = @api.team(@linescore.xpath("//game/@away_name_abbrev").first.value)
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
			@linescore.xpath("//game/@venue").first.value
		end

		def home_start_time
			"#{ @linescore.xpath("//game/@home_time").first.value } #{ @linescore.xpath("//game/@home_time_zone").first.value }"
		end

		def away_start_time
			"#{ @linescore.xpath("//game/@away_time").first.value } #{ @linescore.xpath("//game/@away_time_zone").first.value }"
		end

		# Preview, Pre-Game, In Progress, Final
		def status
			@status ||= @linescore.xpath("//game/@status").first.value
		end

		# [3, Top/Middle/Bottom/End]
		def inning
			[@linescore.xpath("//game/@inning").first.value, @linescore.xpath("//game/@inning_state").first.value]
		end

		def runners
			first, second, third = [nil, nil, nil]

			[first, second, third]
		end

		def over?
			status == "Final"
		end
		alias_method :fat_lady_has_sung?, :over?

		def in_progress?
			status == "In Progress"
		end

		def home_record
			[@linescore.xpath("//game/@home_win").first.value, @linescore.xpath("//game/@home_loss").first.value].map(&:to_i)
		end

		def away_record
			[@linescore.xpath("//game/@away_win").first.value, @linescore.xpath("//game/@away_loss").first.value].map(&:to_i)
		end

		def current_pitcher
			return nil if !in_progress?

			@api.pitcher @linescore.xpath("//game/current_pitcher/@id").first.value
		end

		def opposing_pitcher
			return nil if !in_progress?

			@api.pitcher @linescore.xpath("//game/opposing_pitcher/@id").first.value
		end

		def winning_pitcher
			return nil if !over?

			@api.pitcher @linescore.xpath("//game/winning_pitcher/@id").first.value
		end

		def losing_pitcher
			return nil if !over?

			@api.pitcher @linescore.xpath("//game/losing_pitcher/@id").first.value
		end

		def save_pitcher
			return nil if !over?

			@api.pitcher @linescore.xpath("//game/save_pitcher/@id").first.value
		end

		def score
			return [0, 0] if !in_progress? && !over?

			[@linescore.xpath("//game/@home_team_runs").first.value, @linescore.xpath("//game/@away_team_runs").first.value].map(&:to_i)
		end

		def home_pitcher
			case status
			when "In Progress"
				# The xpath changes based on which half of the inning it is
				if @linescore.xpath("//game/@top_inning").first.value == "Y"
					opposing_pitcher
				else
					current_pitcher
				end
			when "Preview", "Warmup", "Pre-Game"
				@api.pitcher @linescore.xpath("//game/home_probable_pitcher/@id").first.value
			when "Final"
				home, away = score

				if home > away
					winning_pitcher
				elsif away > home
					losing_pitcher
				else
					# Spring training games can end in ties, in which case there's really no pitching data
					# See: http://gd2.mlb.com/components/game/mlb/year_2013/month_03/day_07/gid_2013_03_07_texmlb_lanmlb_1/linescore.xml
					# This should really give a null object pitcher back
					nil
				end
			else
			end
		end

		def away_pitcher
			case status
			when "In Progress"
				# The xpath changes based on which half of the inning it is
				if @linescore.xpath("//game/@top_inning").first.value == "Y"
					current_pitcher
				else
					opposing_pitcher
				end
			when "Preview", "Warmup", "Pre-Game"
				@api.pitcher @linescore.xpath("//game/away_probable_pitcher/@id").first.value
			when "Final"
				home, away = score

				if home > away
					losing_pitcher
				elsif away > home
					winning_pitcher
				else
					# Spring training games can end in ties, in which case there's really no pitching data
					# See: http://gd2.mlb.com/components/game/mlb/year_2013/month_03/day_07/gid_2013_03_07_texmlb_lanmlb_1/linescore.xml
					# This should really give a null object pitcher back
					nil
				end
			else
			end
		end

		def home_tv
			return nil if !@gamecenter

			@gamecenter.xpath("//game/broadcast/home/tv").first.content
		end

		def away_tv
			return nil if !@gamecenter

			@gamecenter.xpath("//game/broadcast/away/tv").first.content
		end

		def home_radio
			return nil if !@gamecenter

			@gamecenter.xpath("//game/broadcast/home/radio").first.content
		end

		def away_radio
			return nil if !@gamecenter

			@gamecenter.xpath("//game/broadcast/away/radio").first.content
		end

		def is_free?
			@linescore.xpath("//game/game_media/media/@free").first.value == "ALL"

		def linescore
			@linescore
		end

		def gamecenter
			@gamecenter
		end
	end
end
