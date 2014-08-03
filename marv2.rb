#!/usr/bin/env ruby

require 'rubygems'
require 'serialport'

temperature = nil
pressure = nil
humidity = nil
discomfort_index = nil

sp = SerialPort.new('/dev/ttyACM0', 9600)
sp.readline
sp.readline
while !(temperature && pressure && humidity && discomfort_index)
  sp.readline =~ /Temperature\t(.+?)\tPressure\t(\d+)\tHumidity\t(\d+)/
  next unless $1 && $2 && $3
  temperature = $1.to_f # Celsius
  pressure = $2.to_i / 100 # hPa
  humidity = $3.to_i # Percentage
  discomfort_index = 0.81 * temperature + 0.01 * humidity * (0.99 * temperature - 14.3) + 46.3
end
sp.close

epoch = Time.now.to_i
puts "temperature.bed_room\t#{temperature}\t#{epoch}"
puts "pressure.bed_room\t#{pressure}\t#{epoch}"
puts "humidity.bed_room\t#{humidity}\t#{epoch}"
puts "discomfort_index.bed_room\t#{discomfort_index}\t#{epoch}"
