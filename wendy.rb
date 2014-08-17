require 'sinatra'
require 'haml'
require 'mongoid'

require_relative 'models/settings'

Mongoid.load!('config/mongoid.yaml')

get '/' do
  @settings = Settings.recent.first || Settings.new
  p @settings
  haml :index
end

post '/settings' do
  settings = Settings.new({
    command: params[:command],
    threshold_low: params[:threshold_low],
    threshold_high: params[:threshold_high],
  })
  halt 503, "failed to save settings: #{settings.errors.full_messages.join(', ')}" unless settings.save
  redirect '/'
end

get '/settings.json' do
  @settings = Settings.recent.first
  halt 404, 'not found' unless @settings
  content_type 'application/json'
  @settings.to_json
end
