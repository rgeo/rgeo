# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Proj4 projection
#
# -----------------------------------------------------------------------------

module RGeo
  module Geographic
    class Proj4Projector # :nodoc:
      def initialize(geography_factory, projection_factory)
        @geography_factory = geography_factory
        @projection_factory = projection_factory
      end

      def set_factories(geography_factory, projection_factory)
        @geography_factory = geography_factory
        @projection_factory = projection_factory
      end

      def project(geometry)
        Feature.cast(geometry, @projection_factory, :project)
      end

      def unproject(geometry)
        Feature.cast(geometry, @geography_factory, :project)
      end

      attr_reader :projection_factory

      def wraps?
        false
      end

      def limits_window
        nil
      end

      class << self
        def create_from_existing_factory(geography_factory, projection_factory)
          new(geography_factory, projection_factory)
        end

        def create_from_proj4(geography_factory, proj4, opts = {})
          projection_factory =
            Cartesian.preferred_factory(
              proj4: proj4,
              coord_sys: opts[:coord_sys], srid: opts[:srid],
              buffer_resolution: opts[:buffer_resolution],
              lenient_multi_polygon_assertions: opts[:lenient_multi_polygon_assertions],
              uses_lenient_assertions: opts[:uses_lenient_assertions],
              has_z_coordinate: opts[:has_z_coordinate],
              has_m_coordinate: opts[:has_m_coordinate],
              wkt_parser: opts[:wkt_parser], wkt_generator: opts[:wkt_generator],
              wkb_parser: opts[:wkb_parser], wkb_generator: opts[:wkb_generator]
            )
          new(geography_factory, projection_factory)
        end
      end
    end
  end
end
