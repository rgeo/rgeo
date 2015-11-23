# -----------------------------------------------------------------------------
#
# Proj4 projection
#
# -----------------------------------------------------------------------------

module RGeo
  module Geographic
    class Proj4Projector # :nodoc:
      def initialize(geography_factory_, projection_factory_)
        @geography_factory = geography_factory_
        @projection_factory = projection_factory_
      end

      def _set_factories(geography_factory_, projection_factory_) # :nodoc:
        @geography_factory = geography_factory_
        @projection_factory = projection_factory_
      end

      def project(geometry_)
        Feature.cast(geometry_, @projection_factory, :project)
      end

      def unproject(geometry_)
        Feature.cast(geometry_, @geography_factory, :project)
      end

      attr_reader :projection_factory

      def wraps?
        false
      end

      def limits_window
        nil
      end

      class << self
        def create_from_existing_factory(geography_factory_, projection_factory_)
          new(geography_factory_, projection_factory_)
        end

        def create_from_proj4(geography_factory_, proj4_, opts_ = {})
          projection_factory_ = Cartesian.preferred_factory(proj4: proj4_,
                                                            coord_sys: opts_[:coord_sys], srid: opts_[:srid],
                                                            buffer_resolution: opts_[:buffer_resolution],
                                                            lenient_multi_polygon_assertions: opts_[:lenient_multi_polygon_assertions],
                                                            uses_lenient_assertions: opts_[:uses_lenient_assertions],
                                                            has_z_coordinate: opts_[:has_z_coordinate],
                                                            has_m_coordinate: opts_[:has_m_coordinate],
                                                            wkt_parser: opts_[:wkt_parser], wkt_generator: opts_[:wkt_generator],
                                                            wkb_parser: opts_[:wkb_parser], wkb_generator: opts_[:wkb_generator])
          new(geography_factory_, projection_factory_)
        end
      end
    end
  end
end
