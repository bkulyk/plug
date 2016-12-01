#!/usr/bin/env ruby
require 'rpi_gpio'

PIN_NUM = 21

RPi::GPIO.set_numbering :bcm
RPi::GPIO.setup PIN_NUM, :as => :output, :initialize => :low

# this needs to be defined before Sinatra does it's initialization or we won't get the chance to run this
at_exit do
  # close the pin "device" so it can be used again later
  # the PiPiper does not seem to have any way to close the pin device, so we'll do it manually
  release_pin
end

require 'sinatra'
set :bind, '0.0.0.0'
set :port, 80

set :static_cache_control, [:public, max_age: 1]

get '/on' do
  RPi::GPIO.set_high PIN_NUM
  take_photo
  redirect '/#on'
end

get '/off' do
  RPi::GPIO.set_low PIN_NUM
  take_photo
  redirect '/#off'
end

get '/' do
  erb :index
end

def take_photo
  puts 'take photo'
  path = File.absolute_path File.join File.dirname(__FILE__), 'public', 'camera.jpeg'
  `raspistill -o #{path}  -hf -vf --nopreview --width 640 --height 480`
end

def release_pin
  RPi::GPIO.reset
end

take_photo