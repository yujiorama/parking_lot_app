require 'rubygems'
require 'bundler'

Bundler.require

require './parking_lot'

run Sinatra::Application
