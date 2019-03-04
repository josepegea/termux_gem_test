class CreateLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :locations do |t|
      t.point :position
      t.float :altitude
      t.float :accuracy
      t.float :speed
      t.float :bearing
      t.string :provider
      t.timestamp :moment
      t.jsonb :raw
    end
    add_index :locations, :moment
  end
end
