module MLBGameday
	class Pitcher < Player
		def name
			@data.xpath("//Player//@first_name").first.value + " " + @data.xpath("//Player//@last_name").first.value
		end

		def era
			@data.xpath("//pitching/season/@era").first.value
		end

		def wins
			@data.xpath("//pitching/season/@w").first.value
		end

		def losses
			@data.xpath("//pitching/season/@l").first.value
		end

		def innings
			@data.xpath("//pitching/season/@ip").first.value
		end

		def saves
			@data.xpath("//pitching/season/@sv").first.value
		end

		def whip
			@data.xpath("//pitching/season/@whip").first.value
		end

		def strikeouts
			@data.xpath("//pitching/season/@so").first.value
		end

		def walks
			@data.xpath("//pitching/season/@bb").first.value
		end

		# Returns a Nokogiri::XML object
		def data
			@data
		end
	end
end
