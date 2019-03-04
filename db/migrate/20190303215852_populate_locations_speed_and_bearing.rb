class PopulateLocationsSpeedAndBearing < ActiveRecord::Migration[5.2]
  def up
    Location.connection.execute(<<~SQL
      UPDATE locations
      SET speed = (raw->>'speed')::FLOAT, bearing = (raw->>'bearing')::FLOAT
      WHERE speed IS NULL OR bearing IS NULL
    SQL
    )
  end

  def down
  end
end
