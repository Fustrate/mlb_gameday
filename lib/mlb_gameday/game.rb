module MLBGameday
  # This class is just too long. It might be able to be split up, but it's not
  # likely to happen any time soon. For now, we'll disable the cop.
  # rubocop:disable Metrics/ClassLength
  class Game
    attr_reader :gid, :home_team, :away_team, :linescore, :gamecenter, :boxscore

    def initialize(api, gid, linescore: nil, gamecenter: nil, boxscore: nil)
      @api = api
      @gid = gid

      @linescore  = linescore
      @gamecenter = gamecenter
      @boxscore   = boxscore

      if linescore
        @home_team = @api.team linescore.xpath('//game/@home_name_abbrev').text
        @away_team = @api.team linescore.xpath('//game/@away_name_abbrev').text
      else
        @home_team = @api.team gamecenter.xpath('//game/@id').text[18, 6]
        @away_team = @api.team gamecenter.xpath('//game/@id').text[11, 6]
      end
    end

    def teams
      [@home_team, @away_team]
    end

    def venue
      return @linescore.xpath('//game/@venue').text if @linescore

      @gamecenter.xpath('//game/venueShort').text
    end

    def home_start_time(ampm: true)
      if ampm
        [
          @linescore.xpath('//game/@home_time').text,
          @linescore.xpath('//game/@home_ampm').text,
          @linescore.xpath('//game/@home_time_zone').text
        ].join ' '
      else
        [
          @linescore.xpath('//game/@home_time').text,
          @linescore.xpath('//game/@home_time_zone').text
        ].join ' '
      end
    end

    def away_start_time(ampm: true)
      if ampm
        [
          @linescore.xpath('//game/@away_time').text,
          @linescore.xpath('//game/@away_ampm').text,
          @linescore.xpath('//game/@away_time_zone').text
        ].join ' '
      else
        [
          @linescore.xpath('//game/@away_time').text,
          @linescore.xpath('//game/@away_time_zone').text
        ].join ' '
      end
    end

    # Preview, Pre-Game, In Progress, Final
    def status
      @status ||= if @linescore
                    @linescore.xpath('//game/@status').text
                  else
                    {
                      'P' => 'Preview',
                      'I' => 'In Progress',
                      'O' => 'Over'
                    }[@gamecenter.xpath('//game/@status').text]
                  end
    end

    # [3, Top/Middle/Bottom/End]
    def inning
      return [0, '?'] unless @linescore && @linescore.xpath('//game/@inning')

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

    def started?
      over? || in_progress?
    end

    def postponed?
      status == 'Postponed'
    end

    def home_record
      return [0, 0] unless @linescore

      [@linescore.xpath('//game/@home_win'),
       @linescore.xpath('//game/@home_loss')].map(&:text).map(&:to_i)
    end

    def away_record
      return [0, 0] unless @linescore

      [@linescore.xpath('//game/@away_win'),
       @linescore.xpath('//game/@away_loss')].map(&:text).map(&:to_i)
    end

    def current_pitcher
      return nil unless in_progress?

      @api.pitcher @linescore.xpath('//game/current_pitcher/@id').text,
                   year: date.year
    end

    def opposing_pitcher
      return nil unless in_progress?

      @api.pitcher @linescore.xpath('//game/opposing_pitcher/@id').text,
                   year: date.year
    end

    def winning_pitcher
      return nil unless over?

      @api.pitcher @linescore.xpath('//game/winning_pitcher/@id').text,
                   year: date.year
    end

    def losing_pitcher
      return nil unless over?

      @api.pitcher @linescore.xpath('//game/losing_pitcher/@id').text,
                   year: date.year
    end

    def save_pitcher
      return nil unless over?

      @api.pitcher @linescore.xpath('//game/save_pitcher/@id').text,
                   year: date.year
    end

    def away_starting_pitcher
      return '' unless @linescore

      @linescore.xpath('//game/away_probable_pitcher/@id').text
    end

    def home_starting_pitcher
      return '' unless @linescore

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

        home > away ? winning_pitcher : losing_pitcher
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

        home > away ? losing_pitcher : winning_pitcher
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
      return false unless @linescore

      @linescore.xpath('//game/game_media/media/@free').text == 'ALL'
    end

    def date
      return Date.today unless @linescore # SUPER KLUDGE

      @date ||= Chronic.parse @linescore.xpath('//game/@original_date').text
    end

    # So we don't get huge printouts
    def inspect
      %(#<MLBGameday::Game @gid="#{@gid}">)
    end
  end
end
