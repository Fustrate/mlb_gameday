require './test/test_helper'

class TestPlayer < MiniTest::Test
  def setup
    @api = MockedApi.new
    @batter = @api.batter("277417", year: 2014)
  end

  def test_name
    assert_equal "Josh Beckett", @batter.name
  end

  def test_career_batting_average
    assert_equal ".142", @batter.career_avg
  end

  def test_bases_loaded_rbi
    assert_equal "0", @batter.loaded_rbi
  end

  def test_invalid_stat
    assert_nil @batter.fastest_lap
  end
end
