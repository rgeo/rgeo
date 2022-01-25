# frozen_string_literal: true

module Geos
  class NullPointerError < Geos::Error
    def initialize(*)
      super('Tried to create a Geometry from a NULL pointer!')
    end
  end

  class InvalidGeometryTypeError < Geos::Error
    def initialize(*)
      super('Invalid geometry type')
    end
  end

  class UnexpectedBooleanResultError < Geos::Error
    def initialize(result)
      super("Unexpected boolean result: #{result}")
    end
  end

  module Tools
    include GeomTypes

    def cast_geometry_ptr(geom_ptr, options = {})
      options = {
        auto_free: true
      }.merge(options)

      raise Geos::NullPointerError if geom_ptr.null?

      klass = case FFIGeos.GEOSGeomTypeId_r(Geos.current_handle_pointer, geom_ptr)
        when GEOS_POINT
          Point
        when GEOS_LINESTRING
          LineString
        when GEOS_LINEARRING
          LinearRing
        when GEOS_POLYGON
          Polygon
        when GEOS_MULTIPOINT
          MultiPoint
        when GEOS_MULTILINESTRING
          MultiLineString
        when GEOS_MULTIPOLYGON
          MultiPolygon
        when GEOS_GEOMETRYCOLLECTION
          GeometryCollection
        else
          raise Geos::InvalidGeometryTypeError.new
      end

      klass.new(geom_ptr, options).tap do |ret|
        if options[:srid]
          ret.srid = options[:srid] || 0
        elsif options[:srid_copy]
          ret.srid = if Geos.srid_copy_policy == :zero
            0
          else
            options[:srid_copy] || 0
          end
        end
      end
    end

    def check_geometry(geom)
      raise TypeError, 'Expected Geos::Geometry' unless geom.is_a?(Geos::Geometry)
    end

    def pick_srid_from_geoms(srid_a, srid_b, policy = Geos.srid_copy_policy)
      policy = Geos.srid_copy_policy_default if policy == :default

      case policy
        when :zero
          0
        when :lenient
          srid_a
        when :strict
          raise Geos::MixedSRIDsError.new(srid_a, srid_b)
        else
          raise ArgumentError, "Unexpected policy value: #{policy}"
      end
    end

    def pick_srid_according_to_policy(srid, policy = Geos.srid_copy_policy)
      policy = Geos.srid_copy_policy_default if policy == :default

      if srid != 0 && policy != :zero
        srid
      else
        0
      end
    end

    def bool_result(result)
      case result
        when 1
          true
        when 0
          false
        else
          raise Geos::UnexpectedBooleanResultError, result
      end
    end

    def bool_to_int(bool)
      if bool
        1
      else
        0
      end
    end

    def check_enum_value(enum, value)
      enum[value] or
        raise TypeError, "Couldn't find valid #{enum.tag} value: #{value}"
    end

    def symbol_for_enum(enum, value)
      if value.is_a?(Symbol)
        value
      else
        enum[value]
      end
    end

    def extract_options!(args)
      if args.last.is_a?(Hash)
        args.pop
      else
        {}
      end
    end

    class << self
      include Geos::Tools
    end
  end
end
