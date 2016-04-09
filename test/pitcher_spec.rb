require './test/test_helper'

class TestPitcher < MiniTest::Test
  def setup
    @api = MockedApi.new
    # @game = @api.game('2014_05_28_cinmlb_lanmlb_1')
    @pitcher = @api.pitcher("124604", year: 2014)
  end

  def test_career_era
    assert_equal "4.81", @pitcher.career_era
  end

  def test_season_era
    assert_equal 4.35, @pitcher.era
  end

  def test_month_ip
    assert_equal "8.0", @pitcher.month_ip
  end

  def test_jersey_number
    assert_equal "28", @pitcher.jersey_number
  end

  def test_invalid_stat
    assert_nil @pitcher.career_touchdowns
  end

end
