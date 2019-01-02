# Rakefile
require "sinatra/activerecord/rake"
require "./gem_test"

namespace :db do
  task :load_config do
  end
end

task :track_location do
  loc = api.location.gps
  return if loc.blank?
  Location.create(position: [loc[:longitude], loc[:latitude]],
                  altitude: loc[:altitude],
                  accuracy: loc[:accuracy],
                  provider: loc[:provider],
                  moment: Time.now - (loc[:elapsedMs] || 0) / 1000,
                  raw: loc)
end

