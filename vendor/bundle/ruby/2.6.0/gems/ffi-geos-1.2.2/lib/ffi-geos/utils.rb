# frozen_string_literal: true

module Geos
  module Utils
    class << self
      include Geos::Tools
      include Geos::GeomTypes

      if FFIGeos.respond_to?(:GEOSOrientationIndex_r)
        # * -1 if reaching P takes a counter-clockwise (left) turn
        # * 1 if reaching P takes a clockwise (right) turn
        # * 0 if P is collinear with A-B
        #
        # Available in GEOS 3.3.0+.
        def orientation_index(ax, ay, bx, by, px, py)
          FFIGeos.GEOSOrientationIndex_r(
            Geos.current_handle_pointer,
            ax, ay, bx, by, px, py
          )
        end
      end

      if FFIGeos.respond_to?(:GEOSRelatePatternMatch_r)
        # Available in GEOS 3.3.0+.
        def relate_match(mat, pat)
          bool_result(FFIGeos.GEOSRelatePatternMatch_r(Geos.current_handle_pointer, mat, pat))
        end
      end

      def create_point(*args)
        options = extract_options!(args)

        if args.length == 1
          cs = args.first
        elsif args.length == 2
          cs = CoordinateSequence.new(1, 2)
          cs.x[0] = args[0].to_f
          cs.y[0] = args[1].to_f
        elsif args.length == 3
          cs = CoordinateSequence.new(1, 3)
          cs.x[0], cs.y[0], cs.z[0] = args.map(&:to_f)
        else
          raise ArgumentError, "Wrong number of arguments (#{args.length} for 1-3)"
        end

        if cs.length != 1
          raise ArgumentError, 'IllegalArgumentException: Point coordinate list must contain a single element'
        end

        cs_dup = cs.dup
        cs_dup.ptr.autorelease = false

        cast_geometry_ptr(FFIGeos.GEOSGeom_createPoint_r(Geos.current_handle_pointer, cs_dup.ptr), srid: options[:srid])
      end

      def create_line_string(cs, options = {})
        cs = cs_from_cs_or_geom(cs)

        if cs.length <= 1 && cs.length != 0
          raise ArgumentError, 'IllegalArgumentException: point array must contain 0 or >1 elements'
        end

        cs_dup = cs.dup
        cs_dup.ptr.autorelease = false

        cast_geometry_ptr(FFIGeos.GEOSGeom_createLineString_r(Geos.current_handle_pointer, cs_dup.ptr), srid: options[:srid])
      end

      def create_linear_ring(cs, options = {})
        cs = cs_from_cs_or_geom(cs)

        if cs.length <= 1 && cs.length != 0
          raise ArgumentError, 'IllegalArgumentException: point array must contain 0 or >1 elements'
        end

        cs.ptr.autorelease = false

        cast_geometry_ptr(FFIGeos.GEOSGeom_createLinearRing_r(Geos.current_handle_pointer, cs.ptr), srid: options[:srid])
      end

      def create_polygon(outer, *args)
        options = extract_options!(args)

        inner_dups = Array(args).flatten.collect do |i|
          force_to_linear_ring(i) or
            raise TypeError, 'Expected inner Array to contain Geos::LinearRing or Geos::CoordinateSequence objects'
        end

        outer_dup = force_to_linear_ring(outer) or
          raise TypeError, 'Expected outer shell to be a Geos::LinearRing or Geos::CoordinateSequence'

        ary = FFI::MemoryPointer.new(:pointer, inner_dups.length)
        ary.write_array_of_pointer(inner_dups.map(&:ptr))

        outer_dup.ptr.autorelease = false
        inner_dups.each do |i|
          i.ptr.autorelease = false
        end

        cast_geometry_ptr(FFIGeos.GEOSGeom_createPolygon_r(Geos.current_handle_pointer, outer_dup.ptr, ary, inner_dups.length), srid: options[:srid])
      end

      def create_empty_point(options = {})
        cast_geometry_ptr(FFIGeos.GEOSGeom_createEmptyPoint_r(Geos.current_handle_pointer), srid: options[:srid])
      end

      def create_empty_line_string(options = {})
        cast_geometry_ptr(FFIGeos.GEOSGeom_createEmptyLineString_r(Geos.current_handle_pointer), srid: options[:srid])
      end

      def create_empty_polygon(options = {})
        cast_geometry_ptr(FFIGeos.GEOSGeom_createEmptyPolygon_r(Geos.current_handle_pointer), srid: options[:srid])
      end

      def create_empty_collection(t, options = {})
        check_enum_value(Geos::GeometryTypes, t)
        cast_geometry_ptr(FFIGeos.GEOSGeom_createEmptyCollection_r(Geos.current_handle_pointer, t), srid: options[:srid])
      end

      def create_empty_multi_point(options = {})
        create_empty_collection(:multi_point, options)
      end

      def create_empty_multi_line_string(options = {})
        create_empty_collection(:multi_line_string, options)
      end

      def create_empty_multi_polygon(options = {})
        create_empty_collection(:multi_polygon, options)
      end

      def create_empty_geometry_collection(options = {})
        create_empty_collection(:geometry_collection, options)
      end

      def create_empty_linear_ring(options = {})
        Geos::WktReader.new.read('LINEARRING EMPTY', options)
      end

      def create_collection(t, *args)
        check_enum_value(Geos::GeometryTypes, t)

        klass = case t
          when GEOS_MULTIPOINT, :multi_point
            Geos::Point
          when GEOS_MULTILINESTRING, :multi_line_string
            Geos::LineString
          when GEOS_MULTIPOLYGON, :multi_polygon
            Geos::Polygon
          when GEOS_GEOMETRYCOLLECTION, :geometry_collection
            Geos::Geometry
        end

        options = extract_options!(args)

        geoms = Array(args).flatten.tap do |i|
          if i.detect { |g| !g.is_a?(klass) }
            raise TypeError, "Expected geoms Array to contain #{klass} objects"
          end
        end

        geoms_dups = geoms.map(&:dup)
        geoms_dups.each do |i|
          i.ptr.autorelease = false
        end

        ary = FFI::MemoryPointer.new(:pointer, geoms.length)
        ary.write_array_of_pointer(geoms_dups.map(&:ptr))

        cast_geometry_ptr(FFIGeos.GEOSGeom_createCollection_r(Geos.current_handle_pointer, t, ary, geoms_dups.length), srid: options[:srid])
      end

      def create_multi_point(*args)
        create_collection(:multi_point, *args)
      end

      def create_multi_line_string(*args)
        create_collection(:multi_line_string, *args)
      end

      def create_multi_polygon(*args)
        create_collection(:multi_polygon, *args)
      end

      def create_geometry_collection(*args)
        create_collection(:geometry_collection, *args)
      end

      private

        def cs_from_cs_or_geom(geom_or_cs)
          case geom_or_cs
            when Array
              Geos::CoordinateSequence.new(geom_or_cs)
            when Geos::CoordinateSequence
              geom_or_cs.dup
          end
        end

        def force_to_linear_ring(geom_or_cs)
          case geom_or_cs
            when Geos::CoordinateSequence
              geom_or_cs.to_linear_ring
            when Geos::LinearRing
              geom_or_cs.dup
          end
        end
    end
  end
end
