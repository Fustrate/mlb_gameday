require 'spec_helper'

# TODO: Mock or stub out the JSON files

describe "An MLB Gameday Game object" do
	before :all do
		@api = MLBGameday::API.new

		@dodgers = @api.team("Dodgers")
		@giants = @api.team("Giants")
	end

	before :each do
		@games = @api.find_games(team: @dodgers, date: Date.parse("2013-04-01"))
	end

	it "should have two starting pitchers" do
		game = @games[0]

		expect(game.teams.count).to eq(2)
	end

	it "should have the correct venue" do
		game = @games[0]

		expect(game.venue).to eq("Dodger Stadium")
	end

	it "should start at the correct time for the home team" do
		game = @games[0]

		expect(game.start_time).to eq("1:10 PT")
	end

	# TODO: Pick another game, LA and SF are both Pacific
	it "should start at the correct time for the away team" do
		game = @games[0]

		expect(game.start_time(@giants)).to eq("1:10 PT")
	end

	it "should have Clayton Kershaw starting" do
	end
end
