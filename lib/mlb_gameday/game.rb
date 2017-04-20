# frozen_string_literal: true

module MLBGameday
  # This class is just too long. It might be able to be split up, but it's not
  # likely to happen any time soon. For now, we'll disable the cop.
  # rubocop:disable Metrics/ClassLength
  class Game
    attr_reader :gid, :home_team, :away_team, :files

    def initialize(api, gid, files = {})
      @api = api
      @gid = gid

      @files = files

      @home_team = @api.team files[:linescore].xpath('//game/@home_team_name').text
      @away_team = @api.team files[:linescore].xpath('//game/@away_team_name').text
    end

    def teams
      [@home_team, @away_team]
    end

    def venue
      if @files[:linescore]
        return @files[:linescore].xpath('//game/@venue').text
      end

      files[:gamecenter].xpath('//game/venueShort').text
    end

    def home_start_time(ampm: true)
      if ampm
        [
          @files[:linescore].xpath('//game/@home_time').text,
          @files[:linescore].xpath('//game/@home_ampm').text,
          @files[:linescore].xpath('//game/@home_time_zone').text
        ].join ' '
      else
        [
          @files[:linescore].xpath('//game/@home_time').text,
          @files[:linescore].xpath('//game/@home_time_zone').text
        ].join ' '
      end
    end

    def away_start_time(ampm: true)
      if ampm
        [
          @files[:linescore].xpath('//game/@away_time').text,
          @files[:linescore].xpath('//game/@away_ampm').text,
          @files[:linescore].xpath('//game/@away_time_zone').text
        ].join ' '
      else
        [
          @files[:linescore].xpath('//game/@away_time').text,
          @files[:linescore].xpath('//game/@away_time_zone').text
        ].join ' '
      end
    end

    # Preview, Pre-Game, In Progress, Final
    def status
      return 'Preview' unless @files[:linescore]

      @status ||= @files[:linescore].xpath('//game/@status').text
    end

    # [3, Top/Middle/Bottom/End]
    def inning
      return [0, '?'] unless @files[:linescore]&.xpath('//game/@inning')

      [
        @files[:linescore].xpath('//game/@inning').text.to_i,
        @files[:linescore].xpath('//game/@inning_state').text
      ]
    end

    def runners
      first = nil
      second = nil
      third = nil

      [first, second, third]
    end

    def over?
      ['Final', 'Game Over', 'Completed Early'].include? status
    end
    alias fat_lady_has_sung? over?

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
      return [0, 0] unless @files[:linescore]

      [
        @files[:linescore].xpath('//game/@home_win'),
        @files[:linescore].xpath('//game/@home_loss')
      ].map(&:text).map(&:to_i)
    end

    def away_record
      return [0, 0] unless @files[:linescore]

      [
        @files[:linescore].xpath('//game/@away_win'),
        @files[:linescore].xpath('//game/@away_loss')
      ].map(&:text).map(&:to_i)
    end

    def current_pitcher
      return nil unless in_progress?

      @api.pitcher @files[:linescore].xpath('//game/current_pitcher/@id').text,
                   year: date.year
    end

    def opposing_pitcher
      return nil unless in_progress?

      @api.pitcher @files[:linescore].xpath('//game/opposing_pitcher/@id').text,
                   year: date.year
    end

    def winning_pitcher
      return nil unless over?

      @api.pitcher @files[:linescore].xpath('//game/winning_pitcher/@id').text,
                   year: date.year
    end

    def losing_pitcher
      return nil unless over?

      @api.pitcher @files[:linescore].xpath('//game/losing_pitcher/@id').text,
                   year: date.year
    end

    def save_pitcher
      return nil unless over?

      @api.pitcher @files[:linescore].xpath('//game/save_pitcher/@id').text,
                   year: date.year
    end

    def away_starting_pitcher
      return '' unless @files[:linescore]

      @files[:linescore].xpath('//game/away_probable_pitcher/@id').text
    end

    def home_starting_pitcher
      return '' unless @files[:linescore]

      @files[:linescore].xpath('//game/home_probable_pitcher/@id').text
    end

    def score
      return [0, 0] unless in_progress? || over?

      [
        @files[:linescore].xpath('//game/@home_team_runs').text,
        @files[:linescore].xpath('//game/@away_team_runs').text
      ].map(&:to_i)
    end

    def home_pitcher
      # Spring training games can end in ties, in which case there's
      # really no pitching data. This should really return a null object.
      case status
      when 'In Progress'
        # The xpath changes based on which half of the inning it is
        if @files[:linescore].xpath('//game/@top_inning').text == 'Y'
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
        if @files[:linescore].xpath('//game/@top_inning').text == 'Y'
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
      return nil unless files[:gamecenter]

      files[:gamecenter].xpath('//game/broadcast/home/tv').text
    end

    def away_tv
      return nil unless files[:gamecenter]

      files[:gamecenter].xpath('//game/broadcast/away/tv').text
    end

    def home_radio
      return nil unless files[:gamecenter]

      files[:gamecenter].xpath('//game/broadcast/home/radio').text
    end

    def away_radio
      return nil unless files[:gamecenter]

      files[:gamecenter].xpath('//game/broadcast/away/radio').text
    end

    def free?
      return false unless @files[:linescore]

      @files[:linescore].xpath('//game/game_media/media/@free').text == 'ALL'
    end

    def date
      return Date.today unless @files[:linescore] # SUPER KLUDGE

      @date ||= Chronic.parse(
        @files[:linescore].xpath('//game/@original_date').text
      )
    end

    def attendance
      @files[:rawboxscore]&.xpath('//boxscore/@attendance')&.text || '0'
    end

    def elapsed_time
      @files[:rawboxscore]&.xpath('//boxscore/@elapsed_time')&.text || ''
    end

    def weather
      @files[:rawboxscore]&.xpath('//boxscore/@weather')&.text || ''
    end

    def wind
      @files[:rawboxscore]&.xpath('//boxscore/@wind')&.text || ''
    end

    def umpires
      return [] unless @files[:rawboxscore]

      umps = {}

      @files[:rawboxscore].xpath('//boxscore/umpires/umpire').each do |umpire|
        umps[umpire.xpath('@position').text] = umpire.xpath('@name').text
      end

      umps
    end

    # So we don't get huge printouts
    def inspect
      %(#<MLBGameday::Game @gid="#{@gid}">)
    end
  end
end
