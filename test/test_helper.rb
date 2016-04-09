require 'minitest/autorun'
require 'mlb_gameday'
# Mock the basic `open` function so we don't actually hit the MLB website
class MockedApi < MLBGameday::API
  alias_method :old_open, :open

  def open(url, &block)
    dir = File.dirname __FILE__
    base = url.gsub 'http://gd2.mlb.com/components/game/mlb/', ''
    path = File.join dir, base

    unless File.exist?(path)
      puts "Downloading from website: #{url}"

      return old_open(url, &block)
    end

    file = File.open path

    return file unless block_given?

    block.call file
  end
end
