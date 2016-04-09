# frozen_string_literal: true
module MLBGameday
  class Player
    attr_reader :id, :data

    def initialize(id:, xml:)
      @id = id
      @data = xml
    end

    def name
      "#{first_name} #{last_name}"
    end

    def method_missing(method_name, *args, &blk)
      # See if it's in Player attributes
      value = player_attribute(method_name)
      return value unless value.empty?

      stat_parts = method_name.to_s.split("_")

      # Child element methods need at least one '_'
      return nil if stat_parts.length == 1

      # Get the stat category
      category = stat_parts.shift
      category = PLAYER_STAT_CATEGORIES[category] if PLAYER_STAT_CATEGORIES[category]

      stat_name = stat_parts.join("_")
      value = detailed_stat(category, stat_name)
      return value unless value.empty?
      nil
    end

  private

  PLAYER_STAT_CATEGORIES =
    {
      "month" => "Month",
      "team" => "Team",
      "empty" => "Empty",
      "men_on" => "Men_On",
      "risp" => "RISP",
      "loaded" => "Loaded",
      "vs_lhb" => "vs_LHB",
      "vs_rhb" => "vs_RHB",
      "vs_b" => "vs_B",
      "vs_b5" => "vs_B5"
    }

    def player_attribute(method_name)
      @data.xpath("//Player/@#{method_name}").text
    end

    def detailed_stat(detail, stat_name)
      @data.xpath("//Player/#{detail}/@#{stat_name}").text
    end

  end
end
