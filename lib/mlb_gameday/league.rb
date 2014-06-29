module MLBGameday
  class League
    attr_reader :name, :divisions

    def initialize(name, divisions)
      @name = name
      @divisions = divisions
    end

    def division(name)
      raise 'Invalid division' unless %i(East Central West).include?(name)

      @divisions[name]
    end
  end
end
