require 'rubygems'
require 'bundler'

Bundler.require

require 'sinatra/base'
require 'sinatra/reloader'
require 'date'
require 'pp'

require './parking_lot.rb'

run ParkingLotApp
