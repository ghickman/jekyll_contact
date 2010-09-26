require 'rubygems'
require 'time'
require 'patron'
require 'nokogiri'

# Setup where we're saving the output.
filename = File.join(
  File.dirname(__FILE__), '..', 'source', '_includes', 'flickr.html')
# Setup http session stuff.
sess = Patron::Session.new
sess.timeout = 30
sess.base_url = 'http://api.flickr.com'
sess.headers['If-Modified-Since'] = File.mtime(filename) if File.exists?(filename)
resp = sess.get '/services/feeds/photos_public.gne?id=39828812@N00&tags=27s&lang=en-us&format=rss_200'

if resp.status == 200
  doc = Nokogiri::XML(resp.body)
  File.open(filename, 'w') do |f|
    f.puts '<div class="flickr_photos">'

    doc.xpath('.//item').sort_by { rand }.slice(0..5).each do |item|
      thumbnail =  item.at_xpath('media:thumbnail')['url']
      link = item.at_xpath('link').text
      title = item.at_xpath('title').text

      f.puts %Q{<span class="flickr_image"><a href="#{link}" title="#{title}"><img src="#{thumbnail}" alt="#{title}" /></a></span>}
    end

    f.puts '</div>'
  end
  mtime = Time.httpdate(resp.headers['Last-Modified'])
  File.utime(mtime, mtime, filename)
end