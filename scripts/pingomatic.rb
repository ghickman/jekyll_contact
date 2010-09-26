require 'rubygems'
require 'open-uri'
require 'nokogiri'

url = "http://pingomatic.com/ping/?title=27smiles&blogurl=http://27smiles.com/" <<
      "&rssurl=http://feeds.feedburner.com/27smiles&chk_blogs=on&chk_technorati=on&chk_feedburner=on" <<
      "&chk_google=on&chk_bloglines=on"

doc = Nokogiri::HTML(open(url))

doc.css('.resultstable tr').each do |row|
  service_name = row.css('td:first').text
  response = row.css('td:last').text

  puts "#{service_name}: #{response}"
end