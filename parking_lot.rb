require 'sinatra/base'
require 'sinatra/reloader'

# Heroku has a limited number of gems installed, and chance is that you need
# some additional gems, like haml. The trick is to vendor them with your app. 
# First, add this snippet, which will add vendor/*/lib to your load path:
Dir['vendor/*'].each do |lib|
  $:.unshift(File.join(File.dirname(__FILE__), lib, 'lib'))
end

class ParkcalcForm
  attr :parkingLot
  attr :startingDate
  attr :startingTime
  attr :startingTimeAMPM
  attr :leavingDate
  attr :leavingTime
  attr :leavingTimeAMPM

  def from(params)
    @parkingLot = params[:parkingLot]
    @startingDate = params[:startingDate]
    @startingTime = paras[:startingTime]
    @startingTimeAMPM = params[:startingTimeAMPM]
    @leavingDate = params[:leavingDate]
    @leavingTime = params[:leavingTime]
    @leavingTimeAMPM = params[:leavingTimeAMPM]
  end
end

class ParkingLotApp < Sinatra::Base
  helpers do
    include Rack::Utils; alias_method :h, :escape_html
  end
  
  def parkingLots
    {"1" => "Valet Parking", "9" => "Takashimaya"}
  end

  get '/parkcalc' do
    @parkingLots = parkingLots
    @estimatedParkingCosts = "$ 0.00"
    erb :parkcalc
  end
  
  post '/parkcalc' do
    form = ParkcalcForm.from(params)
    @estimatedParkingCosts = "$ 12.00"
    erb :parkcalc
  end
end
