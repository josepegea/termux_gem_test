class PopulateSensorPositions < ActiveRecord::Migration[5.2]
  def up
    previous_loc = nil
    first_status = SensorStatus.where("moment IS NOT NULL").order('moment ASC').first
    first_relevant_location = Location.where("moment IS NOT NULL AND moment <= ?", first_status.moment)
                                .order('moment DESC')
                                .first
    Location.where("moment >= ?", first_relevant_location.moment).order('moment ASC').find_each do |l|
      l0 = previous_loc
      previous_loc = l
      next if l0.nil?
      x_diff = l.position.x - l0.position.x
      y_diff = l.position.y - l0.position.y
      t_diff = l.moment - l0.moment
      count = SensorStatus.connection.execute(<<~SQL
        UPDATE sensor_statuses
        SET position = point(
              #{l0.position.x} + (#{x_diff}) * (extract(epoch from (moment - timestamp '#{l0.moment}')) / #{t_diff}),
              #{l0.position.y} + (#{y_diff}) * (extract(epoch from (moment - timestamp '#{l0.moment}')) / #{t_diff})
        )
        WHERE position is NULL
        AND moment >= '#{l0.moment}'
        AND moment <= '#{l.moment}'
      SQL
      )
      puts("#{l.moment} - #{count && count&.cmd_tuples}")
    end
  end

  def down
  end
end
