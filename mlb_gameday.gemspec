# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mlb_gameday/version'

Gem::Specification.new do |spec|
  spec.name          = 'mlb_gameday'
  spec.version       = MLBGameday::VERSION
  spec.authors       = ['Steven Hoffman']
  spec.email         = ['git@fustrate.com']
  spec.description   = 'Access data about games and players from the ' \
                       'official MLB Gameday API'
  spec.summary       = %(Fetches gameday data from the MLB Gameday API)
  spec.homepage      = 'http://github.com/fustrate/mlb_gameday'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($RS)
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = %w[lib]

  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 10.4'
  spec.add_development_dependency 'minitest', '~> 5.5'

  spec.add_dependency 'httparty', '~> 0.13'
  spec.add_dependency 'nokogiri', '~> 1.6'
  spec.add_dependency 'chronic', '~> 0.10'
end
