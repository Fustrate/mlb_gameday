# frozen_string_literal: true

module MLBGameday
  class Pitcher < Player
    def era
      @data.xpath('//Player/season/@era').text.to_f
    end

    def wins
      @data.xpath('//Player/season/@w').text.to_i
    end

    def losses
      @data.xpath('//Player/season/@l').text.to_i
    end

    def innings
      @data.xpath('//Player/season/@ip').text.to_f
    end

    def saves
      @data.xpath('//Player/season/@sv').text.to_i
    end

    def whip
      @data.xpath('//Player/season/@whip').text.to_f
    end

    def strikeouts
      @data.xpath('//Player/season/@so').text.to_i
    end

    def walks
      @data.xpath('//Player/season/@bb').text.to_i
    end
  end
end
