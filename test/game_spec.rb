# frozen_string_literal: true
require './test/test_helper'

class TestGame < MiniTest::Test
  def setup
    @api = MockedApi.new
    @game = @api.game('2014_05_28_cinmlb_lanmlb_1')
    # @free_game = @api.game('2013_04_01_slnmlb_arimlb_1')
  end

  def test_load_game_from_gid
    assert_equal 'Dodgers', @game.home_team.name
  end

  def test_load_game_for_team_on_date
    dodgers = @api.team('Dodgers')

    games = @api.find_games(team: dodgers, date: Date.parse('2014-05-28'))

    assert_equal 1, games.count
  end

  def test_two_teams
    assert_equal 2, @game.teams.count
  end

  def test_correct_venue
    assert_equal 'Dodger Stadium', @game.venue
  end

  def test_home_start_time
    assert_equal '7:10 PM PT', @game.home_start_time
  end

  def test_away_start_time
    assert_equal '10:10 PM ET', @game.away_start_time
  end

  def test_home_starting_pitcher
    assert_equal 'Clayton Kershaw', @game.home_pitcher.name
  end

  def test_home_tv
    assert_equal 'SportsNet LA, SNLA Spanish', @game.home_tv
  end

  def test_away_radio
    assert_equal 'WLW 700, Reds Radio Network', @game.away_radio
  end

  def test_free_game_1
    refute @game.free?
  end

  def test_free_game_2
    skip 'Free game not yet loaded.'

    assert @free_game.free?
  end
end
