#!/usr/bin/env ruby

require 'rubygems'
require 'serialport'
require 'json'

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

# Send to mackerel
api_key = ENV['MACKEREL_API_KEY']
json = [
  {
    name: 'temperature',
    time: epoch,
    value: temperature,
  },
  {
    name: 'pressure',
    time: epoch,
    value: pressure,
  },
  {
    name: 'humidity',
    time: epoch,
    value: humidity,
  },
  {
    name: 'discomfort_index',
    time: epoch,
    value: discomfort_index,
  },
].to_json
p `curl https://mackerel.io/api/v0/services/My-Room/tsdb -H 'X-Api-Key: #{api_key}' -H 'Content-Type: application/json' -X POST -d '#{json}'`
