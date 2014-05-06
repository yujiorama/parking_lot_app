require 'sinatra'

# Heroku has a limited number of gems installed, and chance is that you need
# some additional gems, like haml. The trick is to vendor them with your app. 
# First, add this snippet, which will add vendor/*/lib to your load path:
Dir['vendor/*'].each do |lib|
  $:.unshift(File.join(File.dirname(__FILE__), lib, 'lib'))
end

get '/parkcalc' do
end
