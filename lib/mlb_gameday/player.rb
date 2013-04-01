module MLBGameday
	class Player
		def initialize(api, id, data)
			@api = api
			@id = id
			@data = data
		end

		def id
			@id
		end

		protected

		def xpath(path)
			@data.xpath(path).first.value
		end
	end
end
