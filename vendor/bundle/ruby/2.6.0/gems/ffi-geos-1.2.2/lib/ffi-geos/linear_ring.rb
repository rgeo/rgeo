# frozen_string_literal: true

module Geos
  class LinearRing < LineString
    def to_polygon
      Geos.create_polygon(self, srid: pick_srid_according_to_policy(srid))
    end

    def to_line_string
      Geos.create_line_string(coord_seq, srid: pick_srid_according_to_policy(srid))
    end
  end
end
