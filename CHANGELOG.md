# Changelog

## 0.3.2

* Don't load an extra XML file at the end of the game to find the W/L/S pitcher's stats.

## 0.3.1

* Changed back to gdx - the redirect is gone.

## 0.3.0

* Changed data source to gd-terr-origin.mlb.com since gdx.mlb.com redirects there.
* Code cleanup.

## 0.2.3 / 0.2.4

* Add All Star teams

## 0.2.1 / 0.2.2

* Recognize "d-backs" as a name for the Diamondbacks

## 0.2.0

* Added game attendance, weather, wind, elapsed time, and umpires
* Understand a few more game statuses
* Use Ruby 2.4 lonely operator (&.) **This drops compatibility for Ruby 2.3 and below.**
* Fixed implicit names bug (thanks to @cacqw7) [#4](https://github.com/Fustrate/mlb_gameday/pull/4)
