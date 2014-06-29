require 'spec_helper'

# TODO: Mock or stub out the JSON files

describe 'An MLB Gameday Game object' do
  before :all do
    @api = MLBGameday::API.new

    @game = @api.find_games(team: 'LAD', date: Date.parse('2013-04-01')).first
    @free_game = @api.game('2013_04_01_slnmlb_arimlb_1')
  end

  it 'should have two starting pitchers' do
    expect(@game.teams.count).to eq(2)
  end

  it 'should have the correct venue' do
    expect(@game.venue).to eq('Dodger Stadium')
  end

  it 'should start at the correct time for the home team' do
    expect(@game.home_start_time).to eq('1:10 PM PT')
  end

  # TODO: Pick another game, LA and SF are both Pacific
  it 'should start at the correct time for the away team' do
    expect(@game.away_start_time).to eq('1:10 PM PT')
  end

  it 'should have Clayton Kershaw starting' do
    expect(@game.home_pitcher.name).to eq('Clayton Kershaw')
  end

  it 'should be on Prime Ticket and ESPN in Los Angeles' do
    expect(@game.home_tv).to eq('PRIME, ESPN')
  end

  it 'should be on KNBR 680 in San Francisco' do
    expect(@game.away_radio).to eq('KNBR 680')
  end

  it 'should not be free' do
    expect(@game.free?).to be_false
  end

  it 'should have a free game' do
    expect(@free_game.is_free?).to be_true
  end
end
