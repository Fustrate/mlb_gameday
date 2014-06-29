module MLBGameday
  class Player
    attr_reader :id, :data

    def initialize(id:, xml:)
      @id = id
      @data = xml
    end

    def first_name
      @data.xpath('//Player//@first_name').text
    end

    def last_name
      @data.xpath('//Player//@last_name').text
    end

    def name
      "#{first_name} #{last_name}"
    end
  end
end
