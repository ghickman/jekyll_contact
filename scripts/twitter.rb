$:.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'time'
require 'yaml'
require 'patron'
require 'nokogiri'

require 'date_helpers'
include DateHelpers

# Setup where we're saving the output.
filename = File.join(
  File.dirname(__FILE__), '..', 'source', '_includes', 'twitter.html')
twitter_cache = File.join(
  File.dirname(__FILE__), '..', 'source', '_includes', 'twitter.yml')


begin
  cache = YAML::load_file(twitter_cache)
rescue Errno::ENOENT
end

# Setup http session stuff.
sess = Patron::Session.new
sess.timeout = 30
sess.base_url = 'http://twitter.com'
if cache
  sess.headers['If-Modified-Since'] = cache[:last_modified].utc
  sess.headers['If-None-Match'] = cache[:etag]
end
resp = sess.get '/statuses/user_timeline/14306567.rss'

if resp.status == 200
  doc = Nokogiri::XML(resp.body)

  File.open(filename, 'w') do |f|
    doc.xpath('.//item').each do |item|
      desc = item.at_xpath('description').text
      desc = desc.gsub(/(.+): /, '')

      link = item.at_xpath('link').text
      date = item.at_xpath('pubDate').text

      # Skip items that start with @ don't need those on the site =)
      unless desc =~ /^@/
        # Link up @username
        desc.gsub!(/(?!\s+)@([A-Za-z0-9_]+)/,
          '<a class="user" href="http://twitter.com/\1">@\1</a>')
        # Link up hashtags.
        desc.gsub!(/#([A-Za-z0-9_]+)/,
          '<a class="hash" href="http://twitter.com/#search?q=%23\1">#\1</a>')
        # Finally convert new lines to br's
        desc.gsub!(/\n/, '<br />')

        # write stuff to file.
        f.puts %Q{
          <p class="tweet">
            &#8220;<span>#{desc}</span>&#8221;
          </p>
        }
        f.puts %Q{<p><a href="#{link}">view evidence</a></p>}
        # We only need the first tweet that isn't an @ reply so break out now.
        break
      end
    end
  end

  data = {
    :last_modified => Time.httpdate(resp.headers['Last-Modified']),
    :etag => resp.headers['ETag']
  }

  File.open(twitter_cache, 'w+') { |f| YAML::dump(data, f) }
end