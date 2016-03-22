# frozen_string_literal: true
require 'open-uri'
require 'fileutils'

raise 'Please pass a URL to this program.' if ARGV[0].empty?

def download_url(url)
  response = open(url)

  puts "Downloading #{url}"

  raise "Error downloading #{url}" unless response.status[0] == '200'

  handle_file url, response.read
end

def handle_file(url, body)
  filename = url.gsub 'http://gd2.mlb.com/components/game/mlb/', ''

  if body['Index of']
    body.scan(%r{<li><a href="([^"]+)">\s*(.*)</a></li>}) do |match|
      # Only the "Parent Directory" link is different
      next if match[0] != match[1]

      download_url("#{url}/#{match[0]}")
    end
  else
    # Save the file
    save_file filename, body
  end
end

def save_file(filename, body)
  save_path = File.join Dir.pwd, filename
  FileUtils.mkdir_p File.dirname save_path
  File.open(save_path, 'w') { |file| file.write body }
end

download_url ARGV[0]
