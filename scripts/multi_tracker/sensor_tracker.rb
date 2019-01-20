class SensorTracker
  attr_accessor :api
  attr_accessor :event_queue
  attr_accessor :logger
  
  def initialize(owner)
    @api = owner.api
    @event_queue = owner.event_queue
    @logger = owner.logger
  end

  def run
    Thread.new do
      last_steps = nil
      last_motion_type = nil
      while true do
        begin
          api.sensor.capture(sensors: ['Step Counter', 'Coarse Motion Classifier']) do |reading|
            steps = reading.dig('Step Counter', 'values')&.first
            motion_type = reading.dig('Coarse Motion Classifier', 'values')&.first
            moment = Time.current
            unless steps == last_steps && motion_type == last_motion_type
              real_steps = (steps && last_steps) ? steps - last_steps : 0
              real_steps = steps if real_steps < 0 # The step counter just rolled over
              event_queue << { type: :sensor,
                               moment: moment,
                               data: {
                                 steps: real_steps,
                                 motion_type: motion_type,
                                 raw: reading
                               }}
              last_steps = steps
              last_motion_type = motion_type
            end
          end
        rescue StandardError
          logger.error "Exception in #{self.class.to_s}: #{$!}"
          logger.error "Resuming"
        end
      end
    end
  end
end
