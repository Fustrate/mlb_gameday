module MLBGameday
	class Pitcher < Player
		def name
			xpath("//Player//@first_name") + " " + xpath("//Player//@last_name")
		end

		def era
			xpath("//Player/season/@era")
		end

		def wins
			xpath("//Player/season/@w")
		end

		def losses
			xpath("//Player/season/@l")
		end

		def innings
			xpath("//Player/season/@ip")
		end

		def saves
			xpath("//Player/season/@sv")
		end

		def whip
			xpath("//Player/season/@whip")
		end

		def strikeouts
			xpath("//Player/season/@so")
		end

		def walks
			xpath("//Player/season/@bb")
		end

		# Returns a Nokogiri::XML object
		def data
			@data
		end
	end
end
