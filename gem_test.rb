require 'sinatra'
require 'sinatra/reloader' if development?
require 'pry' if development?
require 'termux_ruby_api'
require 'active_support/all'
require 'securerandom'

enable :sessions
set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }

require "sinatra/activerecord"
require 'pg'

set :database, {adapter: "postgresql", database: "phone_data"}

# ActiveRecord::Base.default_timezone = :utc

require './models.rb'

before do
  authenticate!
end

get '/sign_in' do
  haml :sign_in
end

post '/sign_in' do
  res = api.json_api_command('fingerprint')
  if res && res[:auth_result] == 'AUTH_RESULT_SUCCESS'
    session[:authenticated] = true
    redirect('/')
  else
    redirect('/sign_in')
  end
end

get '/sign_out' do
  session[:authenticated] = false
  redirect('/sign_in')
end

get '/' do
  @steps_today = SensorStatus.today
                   .select("sum(steps) as steps")
                   .order("steps asc")
                   .first
                   .steps
  haml :index
end

get '/call_log' do
  @call_log = api.call_log.log
  haml :call_log
end

get '/speak' do
  haml :speak
end

post '/speak' do
  if params['speak_text'].present?
    api.tts.speak(params['speak_text'])
  end
  redirect "/speak"
end

get '/map' do
  haml :map, layout: :layout_map
end

get '/location_data.json' do
  start_date = get_date_from_params(:start_date, Date.today)
  end_date = get_date_from_params(:end_date, start_date + 1)
  if (day = get_date_from_params(:day))
    start_date = day
    end_date = day + 1
  end
  loc_results = Location
              .select(:moment, :position, :speed, :bearing, :raw)
              .where('moment >= ?', start_date.to_time)
              .where('moment <= ?', end_date.to_time)
              .order(moment: :asc)
  sen_results = SensorStatus
              .select(:moment, :position, :steps, :motion_type, :raw)
              .where('moment >= ?', start_date.to_time)
              .where('moment <= ?', end_date.to_time)
              .order(moment: :asc)

  json_data = {
    path: {
      type: "FeatureCollection",
      features: [
        {
          type: "Feature",
          geometry: {
            type: "LineString",
            coordinates: loc_results.map { |l| [l.position[:x], l.position[:y]] }
          }
        }
      ]
    },
    locations: {
      type: "FeatureCollection",
      features: loc_results.map do |l|
        {
          type: "Feature",
          properties: props_for_location(l),
          geometry: {
            type: "Point",
            coordinates: [l.position[:x], l.position[:y]]
          }
        }
      end
    },
    sensor_statuses: {
      type: "FeatureCollection",
      features: sen_results.select { |s| s.position.present? }.map do |s|
        {
          type: "Feature",
          properties: { moment: s.moment, motion_type: s.motion_type, steps: s.steps },
          geometry: {
            type: "Point",
            coordinates: [s.position[:x], s.position[:y]]
          }
        }
      end
    }
  }
  json_data.to_json
end

def authenticate!
  if request.path_info != '/sign_in' && !session[:authenticated]
    redirect '/sign_in'
  end
end

def link_to(label, *options)
  "<a href=\"#{url(*options)}\">#{label}</a>"
end

def api
  @api ||= TermuxRubyApi::Base.new
end

def get_date_from_params(key, default = nil)
  value_for_key = params[key]
  value_for_key ? Date.parse(value_for_key) : default
end

def props_for_location(l)
  l.attributes.slice(:moment, :position, :altitude, :speed, :bearing)
end
