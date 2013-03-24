module MLBGameday
	class Team
		def initialize(data)
			@name = data[:name]
			@city = data[:city]
			@league = data[:league]
			@division = data[:division]
			@names = data[:names]
		end

		def name
			@name
		end

		def city
			@city
		end

		def league
			@league
		end

		def division
			@division
		end

		def names
			@names
		end
	end
end
