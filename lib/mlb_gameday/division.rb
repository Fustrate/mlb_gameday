module MLBGameday
  class Division
    attr_reader :league, :name, :teams

    def initialize(league, name, teams)
      @league = league
      @name = name
      @teams = teams
    end
  end
end
