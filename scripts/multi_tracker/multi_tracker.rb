require 'active_record'
require 'termux_ruby_api'
require_relative "../../models"
require_relative "../../lib/geo_utils"
require_relative "./location_tracker"
require_relative "./sensor_tracker"

require 'pry'

class MultiTracker

  attr_accessor :api
  attr_accessor :event_queue
  attr_accessor :logger

  def initialize
    @api = TermuxRubyApi::Base.new
    @event_queue = Queue.new
    @logger = Logger.new(File.join(File.dirname(__FILE__), '../../log/multi_tracker.log'), 'daily')
    ActiveRecord::Base.establish_connection(adapter: "postgresql", database: "phone_data")
  end

  def main_loop
    location_tracker = LocationTracker.new(self).run
    sensor_tracker = SensorTracker.new(self).run
    while true do
      begin
        event = event_queue.pop
        process_event(event)
      rescue StandardError
        logger.error "Exception #{$!}"
        logger.error "Resuming"
      end
    end
  end

  def process_event(event)
    send('process_' + event[:type].to_s, event) if [:location, :sensor].include?(event[:type])
  end

  def process_location(event)
    loc = event[:data]
    moment = event[:moment]
    Location.create(position: [loc[:longitude], loc[:latitude]],
                    altitude: loc[:altitude],
                    accuracy: loc[:accuracy],
                    provider: loc[:provider],
                    moment: moment,
                    raw: loc)
    logger.info "Processing location: (#{loc[:longitude]},#{loc[:latitude]}) - #{moment}"
  end

  def process_sensor(event)
    reading = event[:data]
    moment = event[:moment]
    steps = reading[:steps]
    motion_type = reading[:motion_type]
    SensorStatus.create(steps: steps,
                        motion_type: motion_type,
                        moment: moment,
                        raw: reading[:raw])
    logger.info "Processing sensor: Steps:#{steps} Type:#{motion_type} - #{moment}"
  end
end

