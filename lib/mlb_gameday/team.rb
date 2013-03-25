module MLBGameday
	class Team
		def initialize(opts = {})
			@name     = opts[:name]
			@city     = opts[:city]
			@league   = opts[:league]
			@division = opts[:division]
			@names    = opts[:names]
			@code     = opts[:code]
		end

		# So we don't get huge printouts
		def inspect
			%Q{#<MLBGameday::Team @name="#{@name}">}
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

		def code
			@code
		end
	end
end
