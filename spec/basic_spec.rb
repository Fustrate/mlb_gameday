require 'spec_helper'

describe "The basic MLB Gameday API object" do
	before :all do
		@api = MLBGameday::API.new
	end

	it "should be created" do
		expect(@api).to_not eq(nil)
	end

	it "should have 2 leagues" do
		expect(@api.leagues.count).to eq(2)
	end

	it "should have 6 divisions" do
		expect(@api.divisions.count).to eq(6)
	end

	it "should have 30 teams" do
		expect(@api.teams.count).to eq(30)
	end

	it "should find the Dodgers by initials" do
		expect(@api.team("LAD").city).to eq("Los Angeles")
	end

	it "should find the Dodgers by name" do
		expect(@api.team("Dodgers").city).to eq("Los Angeles")
	end

	it "should have 5 teams in the Dodgers' division" do
		expect(@api.team("Dodgers").division.teams.count).to eq(5)
	end

	it "should have the Astros in the AL... West" do
		expect(@api.team("Astros").league.name).to eq("American")
		expect(@api.team("Astros").division.name).to eq("West")
	end

	it "should find one game for the Dodgers on 2013-04-01" do
		dodgers = @api.team("Dodgers")

		games = @api.find_games(team: dodgers, date: Date.parse("2013-04-01"))

		expect(games.count).to eq(1)
	end

	it "should find a game by gid" do
		game = @api.game("2013_04_01_sfnmlb_lanmlb_1")

		expect(game.home_team.name).to eq("Dodgers")
	end
end
