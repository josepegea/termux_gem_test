class LocationTracker
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
      last_loc = nil
      while true do
        begin
          loc = api.location.gps
          logger.info "Got location: #{loc}"
          unless ignore?(loc, last_loc)
            moment = Time.current - (loc[:elapsedMs] || 0) / 1000
            event_queue << { type: :location,
                             moment: moment,
                             data: loc }
            last_loc = loc
          end
          wait_until_next(loc)
        rescue StandardError
          logger.error "Exception in #{self.class.to_s}: #{$!}"
          logger.error "Resuming"
        end
      end
    end
  end

  def ignore?(loc, last_loc)
    return true if loc.blank?
    return false if last_loc.blank?
    return false if loc[:speed] && loc[:speed] > 0
    dist = GeoUtils.distance([loc[:longitude], loc[:latitude]], [last_loc[:longitude], last_loc[:latitude]])
    logger.info "Distance from last_loc: #{dist}. Accuracy: #{loc[:accuracy]}"
    if dist > loc[:accuracy]
      false
    else
      logger.info "Ignoring..."
      true
    end
  end
  
  def wait_until_next(loc)
    speed = loc.present? && loc[:speed] || 0
    delay = case speed
            when 0
              2 * 60
            when 0..1
              60
            when 1..5
              30
            else
              15
            end
    logger.info "Speed: #{speed}. Waiting for #{delay} seconds"
    sleep(delay)
  end
end
