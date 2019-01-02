require 'rgeo'

module GeoUtils
  def self.distance(p1, p2)
    gp1 = factory.point(*p1)
    gp2 = factory.point(*p2)
    gp1.distance(gp2)
  end

  # Factory for Long/Lat coordinates
  def self.factory
    @factory ||= RGeo::Geographic.spherical_factory(:srid => 4326)
  end
end
