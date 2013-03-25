module MLBGameday
	class League
		def initialize(name, divisions)
			@name = name
			@divisions = divisions
		end

		def name
			@name
		end

		def divisions
			@divisions
		end

		def division(name)
			raise "Invalid division" if ![:East, :Central, :West].include?(name)

			@divisions[name]
		end
	end
end
