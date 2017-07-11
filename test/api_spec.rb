# frozen_string_literal: true

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

  def test_name_search_for_nonexistent_returns_nil
    assert_nil @api.team('Senators')
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

  def test_names_includes_alt_names
    @api.teams.each do |team|
      team.send(:alt_names).each do |alt_name|
        assert_includes team.names, alt_name.downcase
      end
    end
  end

  def test_names_include_singular_name_when_different_from_name
    @api.teams
      .reject { |team| team.name == team.send(:singular_name) }
      .each do |team|
        assert_includes team.names, team.send(:singular_name).downcase
      end
  end

  def test_names_includes_despaced_name_when_name_is_multi_word
    @api.teams
      .select { |team| team.name.split.size > 1 }
      .each do |team|
        assert_includes team.names, team.send(:despaced_name).downcase
      end
  end

  def test_names_includes_city_except_nyc_and_chicago
    @api.teams
      .reject { |team| ['New York', 'Chicago'].include?(team.city) }
      .each do |team|
        assert_includes team.names, team.city.downcase
      end
  end

  def test_names_does_not_include_city_for_nyc_and_chicago
    @api.teams
      .select { |team| ['New York', 'Chicago'].include?(team.city) }
      .each do |team|
        refute_includes team.names, team.city.downcase
      end
  end

  def test_no_teams_share_any_names
    @api.teams.each do |team|
      @api.teams.reject { |t| t == team }.each do |other_team|
        assert_equal (team.names - other_team.names), team.names
      end
    end
  end

  def test_all_star_teams
    assert_equal 2, @api.teams.select { |t| t.name['All Stars'] }.length
  end
end
