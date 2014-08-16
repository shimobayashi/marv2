#!/usr/bin/env ruby

require 'rubygems'
require 'serialport'

def fetch(sp)
  temperature = nil
  pressure = nil
  humidity = nil
  discomfort_index = nil
  while !(temperature && pressure && humidity && discomfort_index)
    sp.readline =~ /temperature\t(.+?)\tpressure\t(\d+)\thumidity\t(\d+)/
    next unless $1 && $2 && $3
    temperature = $1.to_f # Celsius
    pressure = $2.to_i / 100 # hPa
    humidity = $3.to_i # Percentage
    discomfort_index = 0.81 * temperature + 0.01 * humidity * (0.99 * temperature - 14.3) + 46.3
  end
  return temperature, pressure, humidity, discomfort_index
end

# Choose center value
temperatures = []
pressures = []
humidities = []
discomfort_indices = []
sp = SerialPort.new('/dev/ttyACM0', 9600, 8, 1, SerialPort::EVEN)
5.times do |i|
  temperature, pressure, humidity, discomfort_index = fetch(sp)
  temperatures << temperature
  pressures << pressure
  humidities << humidity
  discomfort_indices << discomfort_index
end
sp.close
temperature = temperatures.sort[temperatures.size / 2]
pressure = pressures.sort[pressures.size / 2]
humidity = humidities.sort[humidities.size / 2]
discomfort_index = discomfort_indices.sort[discomfort_indices.size / 2]

# Print as Sensu format
epoch = Time.now.to_i
puts "temperature.bed_room\t#{temperature}\t#{epoch}"
puts "pressure.bed_room\t#{pressure}\t#{epoch}"
puts "humidity.bed_room\t#{humidity}\t#{epoch}"
puts "discomfort_index.bed_room\t#{discomfort_index}\t#{epoch}"

#XXX Control air conditioner
require 'yaml'
STATE_YAML = '/home/pi/marv2/state.yaml'
state = File.exist?(STATE_YAML) ? YAML.load_file(STATE_YAML) : {}
state[:aircon] = state[:aircon] || :off
if discomfort_index < 79 && state[:aircon] == :on
  # off
  `irsend SEND_ONCE aircon off`
  state[:aircon] = :off
elsif discomfort_index >= 80 && state[:aircon] == :off
  # on
  `irsend SEND_ONCE aircon on_cooler_27`
  state[:aircon] = :on
end
open(STATE_YAML, 'w') do |f|
  YAML.dump(state, f)
end
