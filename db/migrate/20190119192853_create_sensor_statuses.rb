class CreateSensorStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :sensor_statuses do |t|
      t.integer :steps
      t.integer :motion_type
      t.timestamp :moment
      t.jsonb :raw
    end
  end
end
