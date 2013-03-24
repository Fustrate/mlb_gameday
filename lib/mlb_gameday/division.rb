module MLBGameday
	class Division
		def initialize(league, name, teams)
			@league = league
			@name = name
			@teams = teams
		end

		def league
			@league
		end

		def name
			@name
		end

		def teams
			@teams
		end
	end
end
