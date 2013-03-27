module MLBGameday
	class Player
		def initialize(api, data)
			@api = api
			@data = data
		end

		protected

		def xpath(path)
			@data.xpath(path).first.value
		end
	end
end
