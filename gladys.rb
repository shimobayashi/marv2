#!/usr/bin/env ruby

require 'json'

SENSU_PATH = '/home/pi/marv2/marv2.sensu'

def cooler_on
  `irsend SEND_ONCE aircon on_cooler_27`
  puts "cooloer_on: #{$?}"
end

def off
  `irsend SEND_ONCE aircon off`
  puts "off: #{$?}"
end

# Get settings via STDIN
settings = JSON.parse(STDIN.read)
print "settings: "
p settings

# Get discomfort index
discomfort_index = nil
if File.exist?(SENSU_PATH)
  open(SENSU_PATH).read =~ /^discomfort_index.bed_room\t(.+?)\t\d+$/
  discomfort_index = $1 ? $1.to_f : nil
end
print "discomfort_index: "
p discomfort_index

# Lets do this
case settings['command']
when 'autopilot' then
  # Cooooool
  if discomfort_index
    if discomfort_index < settings['threshold']['low']
      off
    elsif discomfort_index > settings['threshold']['high']
      cooler_on
    end
  end
when 'on' then
  cooler_on
when 'off' then
  off
when 'nop' then
  # No operation
end
