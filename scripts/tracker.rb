require "../gem_test"
require "../lib/geo_utils"
require 'pry'

def main_loop
  last_loc = nil
  while true do
    loc = api.location.gps
    puts "Got location: #{loc}"
    unless ignore?(loc, last_loc)
      last_loc = loc
      Location.create(position: [loc[:longitude], loc[:latitude]],
                      altitude: loc[:altitude],
                      accuracy: loc[:accuracy],
                      provider: loc[:provider],
                      moment: Time.current - (loc[:elapsedMs] || 0) / 1000,
                      raw: loc)
    end
    wait_until_next(loc)
  end
end

def ignore?(loc, last_loc)
  return true if loc.blank?
  return false if last_loc.blank?
  return false if loc[:speed] && loc[:speed] > 0
  dist = GeoUtils.distance([loc[:longitude], loc[:latitude]], [last_loc[:longitude], last_loc[:latitude]])
  puts "Distance from last_loc: #{dist}. Accuracy: #{loc[:accuracy]}"
  if dist > loc[:accuracy]
    false
  else
    puts "Ignoring..."
    true
  end
end

def wait_until_next(loc)
  delay = case loc[:speed]
          when 0
            2 * 60
          when 0..1
            60
          when 1..5
            30
          else
            15
          end
  puts "Speed: #{loc[:speed]}. Waiting for #{delay} seconds"
  sleep(delay)
end

while true do
  begin
    main_loop
  rescue StandardError
    puts "Exception #{$!}"
    puts "Resuming"
  end
end
