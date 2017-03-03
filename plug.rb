#!/usr/bin/env ruby
require 'rpi_gpio'

PIN_NUM = 21

RPi::GPIO.set_numbering :bcm
# RPi::GPIO.setup PIN_NUM, :as => :output, :initialize => :low

Pins = [26, 19, 6, 5]
Pins.each do |pin|
  RPi::GPIO.setup pin, as: :output#, initialize: :low
end

# this needs to be defined before Sinatra does it's initialization or we won't get the chance to run this
at_exit do
  # close the pin "device" so it can be used again later
  # the PiPiper does not seem to have any way to close the pin device, so we'll do it manually
  RPi::GPIO.reset
end

require 'sinatra'
set :bind, '0.0.0.0'
set :port, 80

set :static_cache_control, [:public, max_age: 1]

get '/toggle' do
  pin = params[:pin].to_i
  unless Pins.include? pin
    puts 'invalid pin'
    redirect "/#error"
    return
  end

  RPi::GPIO.set_high pin

  sleep 0.5

  RPi::GPIO.set_low pin
  
#  take_photo
  redirect "/#toggle-#{pin}"
end

get '/' do
  erb :index
end

def take_photo
  puts 'take photo'
  path = File.absolute_path File.join File.dirname(__FILE__), 'public', 'camera.jpeg'
  `raspistill -o #{path}  -hf -vf --nopreview --width 640 --height 480`
end

