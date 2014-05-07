require 'sinatra/base'
require 'sinatra/reloader'

# Heroku has a limited number of gems installed, and chance is that you need
# some additional gems, like haml. The trick is to vendor them with your app. 
# First, add this snippet, which will add vendor/*/lib to your load path:
Dir['vendor/*'].each do |lib|
  $:.unshift(File.join(File.dirname(__FILE__), lib, 'lib'))
end

class ParkingLotApp < Sinatra::Base
  get '/parkcalc' do
    @estimatedParkingCosts = 0
    erb :parkcalc
  end
  
  post '/parkcalc' do
    @estimatedParkingCosts = 12
    erb :parkcalc
  end
end
