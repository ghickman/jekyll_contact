require 'rubygems'
require 'sinatra'
require 'pony'
require 'haml'

set :haml, {:format => :html5}
set :public, File.dirname(__FILE__)
set :views, File.dirname(__FILE__)

# Create the page class and give it a title of Contact for the layout
class Page
  def title
    'Contact'
  end
end

get '/contact' do
  page = Page.new
  content = haml :contact
  haml :contact, :layout=>:'_layouts/default', :locals=>{:page=>page, :content=>content}
end

post '/contact' do
  Pony.mail(:to=>'george@ghickman.co.uk', :from=>"#{params[:mail]}", :subject=>"#{params[:subject]}", :body=>"#{params[:message]}")
  redirect '/index.html'
end