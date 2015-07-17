require 'minitest/autorun'
require 'mlb_gameday.rb'

class TestApi < MiniTest::Test
  def setup
    @api = MLBGameday::API.new
  end

  def test_api_created
    refute_nil @api
  end

  def test_league_count
    assert_equal @api.leagues.count, 2
  end

  def test_division_count
    assert_equal @api.divisions.count, 6
  end

  def test_team_count
    assert_equal @api.teams.count, 30
  end

  def test_initial_search
    assert_equal @api.team('LAD').city, 'Los Angeles'
  end

  def test_name_search
    assert_equal @api.team('Dodgers').city, 'Los Angeles'
  end

  def test_division_team_count
    assert_equal @api.team('Dodgers').division.teams.count, 5
  end

  def test_astros_in_al_west
    assert_equal @api.team('Astros').league.name, 'American'
    assert_equal @api.team('Astros').division.name, 'West'
  end

  def test_names_includes_code
    @api.teams.each do |team|
      assert_includes team.names, team.code.downcase
    end
  end

  def test_names_includes_name
    @api.teams.each do |team|
      assert_includes team.names, team.name.downcase
    end
  end

  def test_names_includes_city_except_nyc_and_chicago
    @api.teams.reject {|team| ["New York", "Chicago"].include?(team.city)}.each do |team|
        assert_includes team.names, team.city.downcase
    end
  end

  def test_names_does_not_include_city_for_nyc_and_chicago
    @api.teams.select {|team| ["New York", "Chicago"].include?(team.city)}.each do |team|
        refute_includes team.names, team.city.downcase
    end
  end
end
