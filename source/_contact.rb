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

def contact
  # create the variables that the layout will expect
  page = Page.new
  content = haml :contact
  
  # render the contact page using jekyll's layout and with our mock jekyll vars
  haml :contact, :layout=>:'_layouts/default', :locals=>{:page=>page, :content=>content}
end

get '/contact' do
  @errors={}
  contact
end

post '/contact' do
  @errors={}
  @errors[:name] = 'No Anon allowed here.' if params[:name].nil? || params[:name].empty?
  @errors[:email] = 'Sinatra needs an email to send your message from!' if params[:email].nil? || params[:email].empty?
  @errors[:message] = 'No message?! Sounds like heavy breathing on the phone to me.' if params[:message].nil? || params[:message].empty?
  
  if @errors.empty?
    Pony.mail(:to=>'george@ghickman.co.uk', :from=>"#{params[:email]}", :subject=>"Contact Message", :body=>"#{params[:message]}")
    redirect 'http://localhost:4000/index.html'
  else
    contact
  end
end



