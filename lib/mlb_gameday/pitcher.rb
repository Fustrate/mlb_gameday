# frozen_string_literal: true
module MLBGameday
  class Pitcher < Player
    def era
      season_era.to_f
    end

    def wins
      season_w.to_i
    end

    def losses
      season_l.to_i
    end

    def innings
      season_ip.to_f
    end

    def saves
      season_sv.to_i
    end

    def whip
      season_whip.to_f
    end

    def strikeouts
      season_so.to_i
    end

    def walks
      season_bb.to_i
    end
  end
end
