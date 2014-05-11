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

  def initialize(params)
    @parkingLot = params[:parkingLot] || ""
    @startingDate = params[:startingDate] || ""
    @startingTime = params[:startingTime] || ""
    @startingTimeAMPM = params[:startingTimeAMPM] || "AM"
    @leavingDate = params[:leavingDate] || ""
    @leavingTime = params[:leavingTime] || ""
    @leavingTimeAMPM = params[:leavingTimeAMPM] || "AM"
  end
  
  def validate
    true
  end
end

class ParkingLot
  attr :value
  attr :label
  attr :selected, true

  def initialize(value, label, selected)
    @value = value
    @label = lavel
    @selected = selected
  end
  def initialize(h)
    @value = h["value"]
    @label = h["label"]
    @selected = h["selected"]
  end
end

module Calculator
  def self.cost(starting, leaving)
    return "$ 0.00" if leaving < starting
    days = (leaving - starting).divmod(24*60*60)
    hours = days[1].divmod(60*60)
    minutes = hours[1].divmod(60)
    #pp starting, leaving, days, hours, minutes

    costs = 0.0

    if days[0] > 0
      costs += days[0] * 18.0
      if hours[0] > 0 || minutes[0] > 0
        costs += 18.0
      end
    else
      if (hours[0] < 5 || (hours[0] == 5 && minutes[0] == 0))
        costs += 12.0
      else
        costs += 18.0
      end
    end
    #pp costs
    return "$ %.2f" % costs
  end
end

class ParkingLotApp < Sinatra::Base
  enable :logging
  register Sinatra::Reloader

  helpers do
    include Rack::Utils; alias_method :h, :escape_html
  end
  
  attr :form, true
  attr :estimatedParkingCosts, true
  
  def form
    return ParkcalcForm.new({}) unless @form
    return @form
  end
  
  def parkingLots
    source = [{"value" => "1", "label" => "Valet Parking", "selected" => false}, {"value" => "9", "label" => "Takashimaya", "selected" => false}]
    source.map { |h|
      ParkingLot.new(h)
    }.map { |e|
      if form && form.parkingLot == e.value
        e.selected = true
      end
      e
    }
  end
  
  def estimatedParkingCosts
    return "$ 0.00" unless @estimatedParkingCosts
    return @estimatedParkingCosts
  end
  
  get '/parkcalc' do
    erb :parkcalc
  end
  
  post '/parkcalc' do
    @form = ParkcalcForm.new(params)
    form.validate
    starting = time_for("#{form.startingDate} #{form.startingTime} #{form.startingTimeAMPM}")
    leaving  = time_for("#{form.leavingDate} #{form.leavingTime} #{form.leavingTimeAMPM}")
    @estimatedParkingCosts = Calculator.cost(starting, leaving)
    erb :parkcalc
  end
end
