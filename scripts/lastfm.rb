$:.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'time'
require 'patron'
require 'nokogiri'

require 'date_helpers'
include DateHelpers

# Setup where we're saving the output.
filename = File.join(File.dirname(__FILE__), '..', 'source', '_includes', 'lastfm.html')
# Setup http session stuff.
sess = Patron::Session.new
sess.timeout = 30
sess.base_url = 'http://ws.audioscrobbler.com'
sess.headers['If-Modified-Since'] = File.mtime(filename)
resp = sess.get '/1.0/user/ghickman/recenttracks.rss'

if resp.status == 200
  doc = Nokogiri::XML(resp.body)

  File.open(filename, 'w') do |f|
    f.puts '<ul class="lastfm_feed">'
    doc.xpath('.//item').slice(0..5).each do |item|
      title = item.at_xpath('title').text
      link = item.at_xpath('link').text
      date = item.at_xpath('pubDate').text

      f.puts %Q{\t<li><a href="#{link}">#{title}</a> #{time_ago_in_words(Time.parse(date))} ago</li>}
    end
    f.puts '</ul>'
  end

  mtime = Time.httpdate(resp.headers['Last-Modified'])
  File.utime(mtime, mtime, filename)
end