module MLBGameday
  class Division
    attr_reader :id, :league, :name, :teams

    def initialize(id:, league:, name:, teams:)
      @id = id
      @league = league
      @name = name
      @teams = teams
    end
  end
end
