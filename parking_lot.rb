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

  @@source = [
      {"value" => "1", "label" => "Valet Parking", "selected" => false},
      {"value" => "2", "label" => "Short-Term Parking", "selected" => false},
      {"value" => "3", "label" => "Economy Parking", "selected" => false},
      {"value" => "9", "label" => "Takashimaya", "selected" => false}
  ]

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

  def self.source
    @@source
  end
end

class ValetCalculator
  def accept(parking_lot)
    "1" == parking_lot
  end

  def cost(starting, leaving)
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

class ShortTermCalculator
  def accept(parking_lot)
    "2" == parking_lot
  end

  def cost(starting, leaving)
    return "$ 0.00" if leaving < starting
    days = (leaving - starting).divmod(24*60*60)
    hours = days[1].divmod(60*60)
    minutes = hours[1].divmod(60)
    pp starting, leaving, days, hours, minutes
    
    costs = 0.00
    total_minutes = 0
    if days[0] > 0
      total_minutes = (days[0] * 24*60*60) + (hours[0] * 60) + minutes[0]
    else
      total_minutes = (hours[0] * 60) + minutes[0]
      if total_minutes <= 60
        costs += 2.00
        total_minutes = 0
      end
    end
    units = total_minutes.divmod(30)
    costs += units[0] * 1.00
    if units[1] > 0
      costs += 1.00
    end
    pp costs, units, total_minutes
    return "$ %.2f" % costs
  end

end

class EconomyCalculator
  def accept(parking_lot)
    "3" == parking_lot
  end

  def cost(starting, leaving)
    return "$ 0.00" if leaving < starting
    days = (leaving - starting).divmod(24*60*60)
    weeks = days[0].divmod(7)
    hours = days[1].divmod(60*60)
    minutes = hours[1].divmod(60)
    pp starting, leaving, days, hours, minutes
    
    costs = 0.00

    if weeks[0] > 0
      costs = 9.0 * (days[0] - weeks[0])
    else
      costs = 9.0 * days[0]
      if (hours[0] >= 5 || (hours[0] == 4 && minutes[0] > 0))
        costs += 9.0
      else
        costs += 2.0 * hours[0]
      end
      
      if minutes[0] > 0
        costs += 2.0
      end
    end

    return "$ %.2f" % costs
  end
end

class Calculator
  
  @@calculators = [ValetCalculator.new, ShortTermCalculator.new, EconomyCalculator.new]

  def self.create(parking_lot)
    @@calculators.each do |e|
      if e.accept(parking_lot)
        return e
      end
    end
    return nil
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
    ParkingLot.source.map { |h|
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
    @estimatedParkingCosts = Calculator.create(form.parkingLot).cost(starting, leaving)
    erb :parkcalc
  end
end
