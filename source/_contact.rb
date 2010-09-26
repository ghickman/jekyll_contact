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
  page = Page.new
  content = haml :contact
  haml :contact, :layout=>:'_layouts/default', :locals=>{:page=>page, :content=>content}
end

get '/contact' do
  # create the variables that the layout will expect
  @errors={}
  # page = Page.new
  # content = haml :contact
  
  # render contact.haml with Jekyll's layout
  # haml :contact, :layout=>:'_layouts/default', :locals=>{:page=>page, :content=>content}
  contact
end

post '/contact' do
  @errors={}
  @errors[:name] = 'No Anon allowed here.' if params[:name].nil? || params[:name].empty?
  @errors[:email] = 'Sinatra needs an email to send your message from!' if params[:email].nil? || params[:email].empty?
  @errors[:message] = 'No message?! Sounds like heavy breathing on the phone to me.' if params[:message].nil? || params[:message].empty?
  
  if @errors.empty?
    Pony.mail(:to=>'george@ghickman.co.uk', :from=>"#{params[:email]}", :subject=>"#{params[:subject]}", :body=>"#{params[:message]}")
    redirect '/index.html'
  else
    contact
  end
end



