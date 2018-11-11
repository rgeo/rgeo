# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Simple mercator projection
#
# -----------------------------------------------------------------------------

module RGeo
  module Geographic
    class SimpleMercatorProjector # :nodoc:
      EQUATORIAL_RADIUS = 6_378_137.0

      def initialize(geography_factory, opts = {})
        @geography_factory = geography_factory
        @projection_factory = Cartesian.preferred_factory(srid: 3857,
                                                          proj4: SimpleMercatorProjector._proj4_3857,
                                                          coord_sys: SimpleMercatorProjector._coordsys_3857,
                                                          buffer_resolution: opts[:buffer_resolution],
                                                          lenient_multi_polygon_assertions: opts[:lenient_multi_polygon_assertions],
                                                          uses_lenient_assertions: opts[:uses_lenient_assertions],
                                                          has_z_coordinate: opts[:has_z_coordinate],
                                                          has_m_coordinate: opts[:has_m_coordinate])
      end

      def set_factories(geography_factory, projection_factory)
        @geography_factory = geography_factory
        @projection_factory = projection_factory
      end

      attr_reader :projection_factory

      def project(geometry)
        case geometry
        when Feature::Point
          rpd_ = ImplHelper::Math::RADIANS_PER_DEGREE
          radius = EQUATORIAL_RADIUS
          @projection_factory.point(geometry.x * rpd_ * radius,
            Math.log(Math.tan(Math::PI / 4.0 + geometry.y * rpd_ / 2.0)) * radius)
        when Feature::Line
          @projection_factory.line(project(geometry.start_point), project(geometry.end_point))
        when Feature::LinearRing
          @projection_factory.linear_ring(geometry.points.map { |p| project(p) })
        when Feature::LineString
          @projection_factory.line_string(geometry.points.map { |p| project(p) })
        when Feature::Polygon
          @projection_factory.polygon(project(geometry.exterior_ring),
                                      geometry.interior_rings.map { |p| project(p) })
        when Feature::MultiPoint
          @projection_factory.multi_point(geometry.map { |p| project(p) })
        when Feature::MultiLineString
          @projection_factory.multi_line_string(geometry.map { |p| project(p) })
        when Feature::MultiPolygon
          @projection_factory.multi_polygon(geometry.map { |p| project(p) })
        when Feature::GeometryCollection
          @projection_factory.collection(geometry.map { |p| project(p) })
        end
      end

      def unproject(geometry)
        case geometry
        when Feature::Point
          dpr = ImplHelper::Math::DEGREES_PER_RADIAN
          radius = EQUATORIAL_RADIUS
          @geography_factory.point(geometry.x / radius * dpr,
            (2.0 * Math.atan(Math.exp(geometry.y / radius)) - Math::PI / 2.0) * dpr)
        when Feature::Line
          @geography_factory.line(unproject(geometry.start_point), unproject(geometry.end_point))
        when Feature::LinearRing
          @geography_factory.linear_ring(geometry.points.map { |p| unproject(p) })
        when Feature::LineString
          @geography_factory.line_string(geometry.points.map { |p| unproject(p) })
        when Feature::Polygon
          @geography_factory.polygon(unproject(geometry.exterior_ring),
            geometry.interior_rings.map { |p| unproject(p) })
        when Feature::MultiPoint
          @geography_factory.multi_point(geometry.map { |p| unproject(p) })
        when Feature::MultiLineString
          @geography_factory.multi_line_string(geometry.map { |p| unproject(p) })
        when Feature::MultiPolygon
          @geography_factory.multi_polygon(geometry.map { |p| unproject(p) })
        when Feature::GeometryCollection
          @geography_factory.collection(geometry.map { |p| unproject(p) })
        end
      end

      def wraps?
        true
      end

      def limits_window
        @limits_window ||= ProjectedWindow.new(@geography_factory,
          -20_037_508.342789, -20_037_508.342789, 20_037_508.342789, 20_037_508.342789,
          is_limits: true)
      end

      def self._proj4_3857 # :nodoc:
        return unless CoordSys.supported?(:proj4)
        unless defined?(@proj4_3857)
          @proj4_3857 = CoordSys::Proj4.create("+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +a=6378137 +b=6378137 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs")
        end
        @proj4_3857
      end

      def self._coordsys_3857 # :nodoc:
        unless defined?(@coordsys_3857)
          @coordsys_3857 = CoordSys::CS.create_from_wkt('PROJCS["Popular Visualisation CRS / Mercator",GEOGCS["Popular Visualisation CRS",DATUM["Popular_Visualisation_Datum",SPHEROID["Popular Visualisation Sphere",6378137,0,AUTHORITY["EPSG","7059"]],TOWGS84[0,0,0,0,0,0,0],AUTHORITY["EPSG","6055"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.01745329251994328,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4055"]],UNIT["metre",1,AUTHORITY["EPSG","9001"]],PROJECTION["Mercator_1SP"],PARAMETER["central_meridian",0],PARAMETER["scale_factor",1],PARAMETER["false_easting",0],PARAMETER["false_northing",0],AUTHORITY["EPSG","3785"],AXIS["X",EAST],AXIS["Y",NORTH]]')
        end
        @coordsys_3857
      end
    end
  end
end
