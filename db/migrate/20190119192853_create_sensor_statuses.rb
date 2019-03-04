class CreateSensorStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :sensor_statuses do |t|
      t.integer :steps
      t.integer :motion_type
      t.timestamp :moment
      t.point :position
      t.jsonb :raw
    end
    add_index :sensor_statuses, :moment
  end
end
