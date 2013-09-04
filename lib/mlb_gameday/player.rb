module MLBGameday
  class Player
    attr_reader :id, :data

    def initialize(api, id, data)
      @api = api
      @id = id
      @data = data
    end

    protected

    def xpath(path)
      @data.xpath(path).first.value
    end
  end
end
