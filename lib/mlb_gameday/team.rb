module MLBGameday
  class Team
    attr_reader :name, :city, :league, :division, :names, :code, :file_code

    def initialize(opts = {})
      @name      = opts[:name]
      @city      = opts[:city]
      @league    = opts[:league]
      @division  = opts[:division]
      @names     = opts[:names]
      @code      = opts[:code]
      @file_code = opts[:file_code]
    end

    # So we don't get huge printouts
    def inspect
      %Q(#<MLBGameday::Team @name="#{@name}">)
    end
  end
end
