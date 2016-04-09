# MlbGameday

## Installation

Add this line to your application's Gemfile:

    gem 'mlb_gameday'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mlb_gameday

## Usage

`require 'mlb_gameday' #=> true`
`gd2 = MLBGameday::API.new`

#### Player
| Methods | | |
|------------------|----|----|
| `bats`| `career_ab`| `career_avg`|
| `career_bb` | `career_era`| `career_h`|
| `career_hr` | `career_ip`| `career_l`|
| `career_rbi`| `career_so`| `career_sv`|
| `career_w`| `career_whip`| `data`|
| `dob`| `empty_ab`| `empty_avg`|
| `empty_bb`| `empty_era`| `empty_h`|
| `empty_hr`| `empty_ip`| `empty_rbi`|
| `empty_so`| `empty_whip`| `first_name`|
| `height`| `id`| `jersey_number`|
| `last_name`| `loaded_ab`| `loaded_avg`|
| `loaded_bb`| `loaded_era`| `loaded_h`|
| `loaded_hr`| `loaded_ip`| `loaded_rbi`|
| `loaded_so`| `loaded_whip`| `men_on_ab`|
| `men_on_avg`| `men_on_bb`| `men_on_era`|
| `men_on_h`| `men_on_hr`| `men_on_ip`|
| `men_on_rbi`| `men_on_so`| `men_on_whip`|
| `month_ab`| `month_avg`| `month_bb`|
| `month_des`| `month_era`| `month_h`|
| `month_hr`| `month_ip`| `month_rbi`|
| `month_so`| `month_whip`| `name`|
| `pitch_out`| `player_attribute_methods`| `player_stat_methods`|
| `pos`| `risp_ab`| `risp_avg`|
| `risp_bb` | `risp_era`| `risp_h`|
| `risp_hr`| `risp_ip`| `risp_rbi`|
| `risp_so`| `risp_whip`| `season_ab`|
| `season_avg`| `season_bb`| `season_era`|
| `season_h`| `season_hr`| `season_ip`|
| `season_l`| `season_rbi`| `season_so`|
| `season_sv`| `season_w`| `season_whip`|
| `team`| `team_ab`| `team_avg`|
| `team_bb`| `team_des`| `team_era`|
| `team_h`| `team_hr`| `team_ip`|
| `team_rbi`| `team_so`| `team_whip`|
| `throws`| `type`| `vs_b5_ab`|
| `vs_b5_avg`| `vs_b5_bb`| `vs_b5_des`|
| `vs_b5_era`| `vs_b5_h`| `vs_b5_hr`|
| `vs_b5_ip`| `vs_b5_rbi`| `vs_b5_so`|
| `vs_b5_whip`| `vs_b_ab`| `vs_b_avg`|
| `vs_b_bb`| `vs_b_des`| `vs_b_era`|
| `vs_b_h`| `vs_b_hr`| `vs_b_ip`|
| `vs_b_rbi`| `vs_b_so`| `vs_b_whip`|
| `vs_lhb_ab`| `vs_lhb_avg`| `vs_lhb_bb`|
| `vs_lhb_era`| `vs_lhb_h`| `vs_lhb_hr`|
| `vs_lhb_ip`| `vs_lhb_rbi`| `vs_lhb_so`|
| `vs_lhb_whip`| `vs_rhb_ab`| `vs_rhb_avg`|
| `vs_rhb_bb`| `vs_rhb_era`| `vs_rhb_h`|
| `vs_rhb_hr`| `vs_rhb_ip`| `vs_rhb_rbi`|
| `vs_rhb_so`| `vs_rhb_whip`| `weight`|

#### Pitcher
_Player methods plus: (current season)_

| Methods | | |
|------------------|----|----|
| `era` | `wins` | `losses` |
| `innings` | `saves` | `whip` |
| `strikeouts` | `walks` | |

#### Game
| Methods | | |
|------------------|----|----|
| `ampm` | `aw_lg_ampm` | `away_ampm` |
| `away_code` | `away_division` | `away_file_code` |
| `away_games_back` | `away_games_back_wildcard` | `away_league_id` |
| `away_loss` | `away_name_abbrev` | `away_pitcher` |
| `away_preview_link` | `away_radio` | `away_recap_link` |
| `away_record` | `away_sport_code` | `away_start_time` |
| `away_starting_pitcher` | `away_team` | `away_team_city` |
| `away_team_errors` | `away_team_hits` | `away_team_id` |
| `away_team_name` | `away_team_runs` | `away_time` |
| `away_time_zone` | `away_tv` | `away_win` |
| `balls` | `boxscore` | `current_linescore` |
| `current_pitcher` | `date` | `day` |
| `define_game_attribute_methods` | `double_header_sw` | `fat_lady_has_sung?` |
| `first_pitch_et` | `free?` | `game_data_directory` |
| `game_nbr` | `game_pk` | `game_type` |
| `gamecenter` | `gameday_link` | `gameday_sw` |
| `gid` | `hm_lg_ampm` | `home_ampm` |
| `home_code` | `home_division` | `home_file_code` |
| `home_games_back` | `home_league_id` | `home_loss` |
| `home_name_abbrev` | `home_pitcher` | `home_preview_link` |
| `home_radio` | `home_recap_link` | `home_record` |
| `home_sport_code` | `home_start_time` | `home_starting_pitcher` |
| `home_team` | `home_team_city` | `home_team_errors` |
| `home_team_hits` | `home_team_id` | `home_team_name` |
| `home_team_runs` | `home_time` | `home_time_zone` |
| `home_tv` | `home_win` | `id` |
| `in_progress?` | `ind` | `inning` |
| `inning_state` | `inspect` | `league` |
| `linescore` | `losing_pitcher` | `note` |
| `opposing_pitcher` | `original_date` | `outs` |
| `over?` | `photos_link` | `postponed?` |
| `preview` | `runners` | `save_pitcher` |
| `scheduled_innings` | `score` | `started?` |
| `status` | `strikes` | `tbd_flag` |
| `teams` | `tiebreaker_sw` | `tied?` |
| `time` | `time_aw_lg` | `time_date` |
| `time_date_aw_lg` | `time_date_hm_lg` | `time_hm_lg` |
| `time_zone` | `time_zone_aw_lg` | `time_zone_hm_lg` |
| `top_inning` | `tv_station` | `tz_aw_lg_gen` |
| `tz_hm_lg_gen` | `venue` | `venue_id` |
| `venue_w_chan_loc` | `winning_pitcher` | `wrapup_link` |

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
