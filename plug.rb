require 'pi_piper'

pin = PiPiper::Pin.new(pin: 21, direction: :out)
pin.off

at_exit { `echo 21 > /sys/class/gpio/unexport` }

include PiPiper

require 'sinatra'
set :bind, '0.0.0.0'
set :port, 3000

before do
  cache_control :public, :must_revalidate, :max_age => 1
end

get '/on' do
	pin.on
        take_photo
	redirect '/#on'
end

get '/off' do
	pin.off
        take_photo
	redirect '/#off'
end

get '/' do
	erb :index
end

get '/camera.jpeg' do
        File.read(File.join('public', 'camera.jpeg'))
end

def take_photo
        #`raspistill -vf -hf -ex auto -q 50 -w 400 -h 300 -o /home/pi/camera.jpeg`
        `raspistill -vf -hf --nopreview --timeout 1 --width 640 --height 480 --quality 80 --output /home/pi/camera.jpeg`
end
