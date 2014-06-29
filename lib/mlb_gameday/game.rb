module MLBGameday
  class Game
    attr_reader :gid, :home_team, :away_team, :linescore, :gamecenter, :boxscore

    def initialize(api, gid, linescore: nil, gamecenter: nil, boxscore: nil)
      @api = api
      @gid = gid

      @linescore  = linescore
      @gamecenter = gamecenter
      @boxscore   = boxscore

      @home_team = @api.team linescore.xpath('//game/@home_name_abbrev').text
      @away_team = @api.team linescore.xpath('//game/@away_name_abbrev').text
    end

    def teams
      [@home_team, @away_team]
    end

    def venue
      @linescore.xpath('//game/@venue').text
    end

    def home_start_time(ampm: true)
      if ampm
        "#{@linescore.xpath('//game/@home_time').text} #{@linescore.xpath('//game/@home_ampm').text} #{@linescore.xpath('//game/@home_time_zone').text}"
      else
        "#{@linescore.xpath('//game/@home_time').text} #{@linescore.xpath('//game/@home_time_zone').text}"
      end
    end

    def away_start_time(ampm: true)
      if ampm
        "#{@linescore.xpath('//game/@away_time').text} #{@linescore.xpath('//game/@away_ampm').text} #{@linescore.xpath('//game/@away_time_zone').text}"
      else
        "#{@linescore.xpath('//game/@away_time').text} #{@linescore.xpath('//game/@away_time_zone').text}"
      end
    end

    # Preview, Pre-Game, In Progress, Final
    def status
      @status ||= @linescore.xpath('//game/@status').text
    end

    # [3, Top/Middle/Bottom/End]
    def inning
      return [0, '?'] unless @linescore.xpath('//game/@inning')

      [@linescore.xpath('//game/@inning').text.to_i,
       @linescore.xpath('//game/@inning_state').text]
    end

    def runners
      first, second, third = [nil, nil, nil]

      [first, second, third]
    end

    def over?
      ['Final', 'Game Over', 'Completed Early'].include? status
    end
    alias_method :fat_lady_has_sung?, :over?

    def in_progress?
      status == 'In Progress'
    end

    def home_record
      [@linescore.xpath('//game/@home_win'),
       @linescore.xpath('//game/@home_loss')].map(&:text).map(&:to_i)
    end

    def away_record
      [@linescore.xpath('//game/@away_win'),
       @linescore.xpath('//game/@away_loss')].map(&:text).map(&:to_i)
    end

    def current_pitcher
      return nil unless in_progress?

      @api.pitcher @linescore.xpath('//game/current_pitcher/@id').text
    end

    def opposing_pitcher
      return nil unless in_progress?

      @api.pitcher @linescore.xpath('//game/opposing_pitcher/@id').text
    end

    def winning_pitcher
      return nil unless over?

      @api.pitcher @linescore.xpath('//game/winning_pitcher/@id').text
    end

    def losing_pitcher
      return nil unless over?

      @api.pitcher @linescore.xpath('//game/losing_pitcher/@id').text
    end

    def save_pitcher
      return nil unless over?

      @api.pitcher @linescore.xpath('//game/save_pitcher/@id').text
    end

    def away_starting_pitcher
      @linescore.xpath('//game/away_probable_pitcher/@id').text
    end

    def home_starting_pitcher
      @linescore.xpath('//game/home_probable_pitcher/@id').text
    end

    def score
      return [0, 0] unless in_progress? || over?

      [@linescore.xpath('//game/@home_team_runs').text,
       @linescore.xpath('//game/@away_team_runs').text].map(&:to_i)
    end

    def home_pitcher
      # Spring training games can end in ties, in which case there's
      # really no pitching data. This should really return a null object.
      case status
      when 'In Progress'
        # The xpath changes based on which half of the inning it is
        if @linescore.xpath('//game/@top_inning').text == 'Y'
          opposing_pitcher
        else
          current_pitcher
        end
      when 'Preview', 'Warmup', 'Pre-Game'
        @api.pitcher home_starting_pitcher
      when 'Final'
        home, away = score

        if home > away
          winning_pitcher
        elsif away > home
          losing_pitcher
        end
      end
    end

    def away_pitcher
      # Spring training games can end in ties, in which case there's
      # really no pitching data. This should really return a null object.
      case status
      when 'In Progress'
        # The xpath changes based on which half of the inning it is
        if @linescore.xpath('//game/@top_inning').text == 'Y'
          current_pitcher
        else
          opposing_pitcher
        end
      when 'Preview', 'Warmup', 'Pre-Game'
        @api.pitcher away_starting_pitcher
      when 'Final', 'Game Over'
        home, away = score

        if home > away
          losing_pitcher
        elsif away > home
          winning_pitcher
        end
      end
    end

    def home_tv
      return nil unless @gamecenter

      @gamecenter.xpath('//game/broadcast/home/tv').text
    end

    def away_tv
      return nil unless @gamecenter

      @gamecenter.xpath('//game/broadcast/away/tv').text
    end

    def home_radio
      return nil unless @gamecenter

      @gamecenter.xpath('//game/broadcast/home/radio').text
    end

    def away_radio
      return nil unless @gamecenter

      @gamecenter.xpath('//game/broadcast/away/radio').text
    end

    def free?
      @linescore.xpath('//game/game_media/media/@free').text == 'ALL'
    end

    def date
      @date ||= DateTime.strptime(@linescore.xpath('//game/@original_date').text, '%Y/%m/%d').to_date
    end

    # So we don't get huge printouts
    def inspect
      %Q(#<MLBGameday::Game @gid="#{@gid}">)
    end
  end
end
