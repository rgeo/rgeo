# frozen_string_literal: true

module Geos
  class Geometry
    include Geos::Tools

    attr_reader :ptr

    class CouldntNormalizeError < Geos::Error
      def initialize(klass)
        super("Couldn't normalize #{klass}")
      end
    end

    # For internal use. Geometry objects should be created via WkbReader,
    # WktReader and the various Geos.create_* methods.
    def initialize(ptr, options = {})
      options = {
        auto_free: true
      }.merge(options)

      @ptr = FFI::AutoPointer.new(
        ptr,
        self.class.method(:release)
      )

      @ptr.autorelease = !!options[:auto_free]
      @parent = options[:parent] if options[:parent]
    end

    def initialize_copy(source)
      @ptr = FFI::AutoPointer.new(
        FFIGeos.GEOSGeom_clone_r(Geos.current_handle_pointer, source.ptr),
        self.class.method(:release)
      )

      # Copy over SRID since GEOS does not
      self.srid = source.srid
    end

    def self.release(ptr) #:nodoc:
      FFIGeos.GEOSGeom_destroy_r(Geos.current_handle_pointer, ptr)
    end

    # Returns the name of the Geometry type, i.e. "Point", "Polygon", etc.
    def geom_type
      FFIGeos.GEOSGeomType_r(Geos.current_handle_pointer, ptr)
    end

    # Returns one of the values from Geos::GeomTypes.
    def type_id
      FFIGeos.GEOSGeomTypeId_r(Geos.current_handle_pointer, ptr)
    end

    def normalize!
      if FFIGeos.GEOSNormalize_r(Geos.current_handle_pointer, ptr) == -1
        raise Geos::Geometry::CouldntNormalizeError, self.class
      end

      self
    end
    alias normalize normalize!

    def srid
      FFIGeos.GEOSGetSRID_r(Geos.current_handle_pointer, ptr)
    end

    def srid=(s)
      FFIGeos.GEOSSetSRID_r(Geos.current_handle_pointer, ptr, s)
    end

    def dimensions
      FFIGeos.GEOSGeom_getDimensions_r(Geos.current_handle_pointer, ptr)
    end

    def num_geometries
      FFIGeos.GEOSGetNumGeometries_r(Geos.current_handle_pointer, ptr)
    end

    def num_coordinates
      FFIGeos.GEOSGetNumCoordinates_r(Geos.current_handle_pointer, ptr)
    end

    def coord_seq
      CoordinateSequence.new(FFIGeos.GEOSGeom_getCoordSeq_r(Geos.current_handle_pointer, ptr), false, self)
    end

    def intersection(geom)
      check_geometry(geom)
      cast_geometry_ptr(FFIGeos.GEOSIntersection_r(Geos.current_handle_pointer, ptr, geom.ptr), srid_copy: pick_srid_from_geoms(srid, geom.srid))
    end

    if FFIGeos.respond_to?(:GEOSBufferWithParams_r)
      # :call-seq:
      #   buffer(width)
      #   buffer(width, options)
      #   buffer(width, buffer_params)
      #   buffer(width, quad_segs)
      #
      # Calls buffer on the Geometry. Options can be passed as either a
      # BufferParams object, as an equivalent Hash or as a quad_segs value.
      # Default values can be found in Geos::Constants::BUFFER_PARAM_DEFAULTS.
      #
      # Note that when using versions of GEOS prior to 3.3.0, only the
      # quad_segs option is recognized when using Geometry#buffer and other
      # options are ignored.
      def buffer(width, options = nil)
        options ||= {}
        params = case options
          when Hash
            Geos::BufferParams.new(options)
          when Geos::BufferParams
            options
          when Numeric
            Geos::BufferParams.new(quad_segs: options)
          else
            raise ArgumentError, 'Expected Geos::BufferParams, a Hash or a Numeric'
        end

        cast_geometry_ptr(FFIGeos.GEOSBufferWithParams_r(Geos.current_handle_pointer, ptr, params.ptr, width), srid_copy: srid)
      end
    else
      def buffer(width, options = nil)
        options ||= {}
        quad_segs = case options
          when Hash
            Geos::BufferParams.new(options).quad_segs
          when Geos::BufferParams
            options.quad_segs
          when Numeric
            options
          else
            raise ArgumentError, 'Expected Geos::BufferParams, a Hash or a Numeric'
        end

        cast_geometry_ptr(FFIGeos.GEOSBuffer_r(Geos.current_handle_pointer, ptr, width, quad_segs), srid_copy: srid)
      end
    end

    def convex_hull
      cast_geometry_ptr(FFIGeos.GEOSConvexHull_r(Geos.current_handle_pointer, ptr), srid_copy: srid)
    end

    def difference(geom)
      check_geometry(geom)
      cast_geometry_ptr(FFIGeos.GEOSDifference_r(Geos.current_handle_pointer, ptr, geom.ptr), srid_copy: pick_srid_from_geoms(srid, geom.srid))
    end

    def sym_difference(geom)
      check_geometry(geom)
      cast_geometry_ptr(FFIGeos.GEOSSymDifference_r(Geos.current_handle_pointer, ptr, geom.ptr), srid_copy: pick_srid_from_geoms(srid, geom.srid))
    end
    alias symmetric_difference sym_difference

    def boundary
      cast_geometry_ptr(FFIGeos.GEOSBoundary_r(Geos.current_handle_pointer, ptr), srid_copy: srid)
    end

    # Calling without a geom argument is equivalent to calling unary_union when
    # using GEOS 3.3+ and is equivalent to calling union_cascaded in older
    # versions.
    def union(geom = nil)
      if geom
        check_geometry(geom)
        cast_geometry_ptr(FFIGeos.GEOSUnion_r(Geos.current_handle_pointer, ptr, geom.ptr), srid_copy: pick_srid_from_geoms(srid, geom.srid))
      else
        if respond_to?(:unary_union)
          unary_union
        else
          union_cascaded
        end
      end
    end

    def union_cascaded
      cast_geometry_ptr(FFIGeos.GEOSUnionCascaded_r(Geos.current_handle_pointer, ptr), srid_copy: srid)
    end

    if FFIGeos.respond_to?(:GEOSUnaryUnion_r)
      # Available in GEOS 3.3+
      def unary_union
        cast_geometry_ptr(FFIGeos.GEOSUnaryUnion_r(Geos.current_handle_pointer, ptr), srid_copy: srid)
      end
    end

    if FFIGeos.respond_to?(:GEOSNode_r)
      # Available in GEOS 3.3.4+
      def node
        cast_geometry_ptr(FFIGeos.GEOSNode_r(Geos.current_handle_pointer, ptr))
      end
    end

    def point_on_surface
      cast_geometry_ptr(FFIGeos.GEOSPointOnSurface_r(Geos.current_handle_pointer, ptr), srid_copy: srid)
    end
    alias representative_point point_on_surface

    if FFIGeos.respond_to?(:GEOSClipByRect_r)
      # Available in GEOS 3.5.0+.
      def clip_by_rect(xmin, ymin, xmax, ymax)
        cast_geometry_ptr(FFIGeos.GEOSClipByRect_r(Geos.current_handle_pointer, ptr, xmin, ymin, xmax, ymax))
      end
      alias clip_by_rectangle clip_by_rect
    end

    def centroid
      cast_geometry_ptr(FFIGeos.GEOSGetCentroid_r(Geos.current_handle_pointer, ptr), srid_copy: srid)
    end
    alias center centroid

    def envelope
      cast_geometry_ptr(FFIGeos.GEOSEnvelope_r(Geos.current_handle_pointer, ptr), srid_copy: srid)
    end

    # Returns the Dimensionally Extended Nine-Intersection Model (DE-9IM)
    # matrix of the geometries as a String.
    def relate(geom)
      check_geometry(geom)
      FFIGeos.GEOSRelate_r(Geos.current_handle_pointer, ptr, geom.ptr)
    end

    # Checks the DE-9IM pattern against the geoms.
    def relate_pattern(geom, pattern)
      check_geometry(geom)
      bool_result(FFIGeos.GEOSRelatePattern_r(Geos.current_handle_pointer, ptr, geom.ptr, pattern))
    end

    if FFIGeos.respond_to?(:GEOSRelateBoundaryNodeRule_r)
      # Available in GEOS 3.3+.
      def relate_boundary_node_rule(geom, bnr = :mod2)
        check_geometry(geom)
        check_enum_value(Geos::RelateBoundaryNodeRules, bnr)
        FFIGeos.GEOSRelateBoundaryNodeRule_r(Geos.current_handle_pointer, ptr, geom.ptr, bnr)
      end
    end

    def line_merge
      cast_geometry_ptr(FFIGeos.GEOSLineMerge_r(Geos.current_handle_pointer, ptr), srid_copy: srid)
    end

    def simplify(tolerance)
      cast_geometry_ptr(FFIGeos.GEOSSimplify_r(Geos.current_handle_pointer, ptr, tolerance), srid_copy: srid)
    end

    def topology_preserve_simplify(tolerance)
      cast_geometry_ptr(FFIGeos.GEOSTopologyPreserveSimplify_r(Geos.current_handle_pointer, ptr, tolerance), srid_copy: srid)
    end

    def extract_unique_points
      cast_geometry_ptr(FFIGeos.GEOSGeom_extractUniquePoints_r(Geos.current_handle_pointer, ptr), srid_copy: srid)
    end
    alias unique_points extract_unique_points

    def disjoint?(geom)
      check_geometry(geom)
      bool_result(FFIGeos.GEOSDisjoint_r(Geos.current_handle_pointer, ptr, geom.ptr))
    end

    def touches?(geom)
      check_geometry(geom)
      bool_result(FFIGeos.GEOSTouches_r(Geos.current_handle_pointer, ptr, geom.ptr))
    end

    def intersects?(geom)
      check_geometry(geom)
      bool_result(FFIGeos.GEOSIntersects_r(Geos.current_handle_pointer, ptr, geom.ptr))
    end

    def crosses?(geom)
      check_geometry(geom)
      bool_result(FFIGeos.GEOSCrosses_r(Geos.current_handle_pointer, ptr, geom.ptr))
    end

    def within?(geom)
      check_geometry(geom)
      bool_result(FFIGeos.GEOSWithin_r(Geos.current_handle_pointer, ptr, geom.ptr))
    end

    def contains?(geom)
      check_geometry(geom)
      bool_result(FFIGeos.GEOSContains_r(Geos.current_handle_pointer, ptr, geom.ptr))
    end

    def overlaps?(geom)
      check_geometry(geom)
      bool_result(FFIGeos.GEOSOverlaps_r(Geos.current_handle_pointer, ptr, geom.ptr))
    end

    if FFIGeos.respond_to?(:GEOSCovers_r)
      # In GEOS versions 3.3+, the native GEOSCoveredBy method will be used,
      # while in older GEOS versions we'll use a relate_pattern-based
      # implementation.
      def covers?(geom)
        check_geometry(geom)
        bool_result(FFIGeos.GEOSCovers_r(Geos.current_handle_pointer, ptr, geom.ptr))
      end
    else
      def covers?(geom) #:nodoc:
        check_geometry(geom)
        !!%w{
          T*****FF*
          *T****FF*
          ***T**FF*
          ****T*FF*
        }.detect do |pattern|
          relate_pattern(geom, pattern)
        end
      end
    end

    if FFIGeos.respond_to?(:GEOSCoveredBy_r)
      # In GEOS versions 3.3+, the native GEOSCovers method will be used,
      # while in older GEOS versions we'll use a relate_pattern-based
      # implementation.
      def covered_by?(geom)
        check_geometry(geom)
        bool_result(FFIGeos.GEOSCoveredBy_r(Geos.current_handle_pointer, ptr, geom.ptr))
      end
    else
      def covered_by?(geom) #:nodoc:
        check_geometry(geom)
        !!%w{
          T*F**F***
          *TF**F***
          **FT*F***
          **F*TF***
        }.detect do |pattern|
          relate_pattern(geom, pattern)
        end
      end
    end

    def eql?(other)
      check_geometry(other)
      bool_result(FFIGeos.GEOSEquals_r(Geos.current_handle_pointer, ptr, other.ptr))
    end
    alias equals? eql?

    def ==(other)
      return eql?(other) if other.is_a?(Geos::Geometry)

      false
    end

    def eql_exact?(other, tolerance)
      check_geometry(other)
      bool_result(FFIGeos.GEOSEqualsExact_r(Geos.current_handle_pointer, ptr, other.ptr, tolerance))
    end
    alias equals_exact? eql_exact?
    alias exactly_equals? eql_exact?

    def eql_almost?(other, decimal = 6)
      check_geometry(other)
      bool_result(FFIGeos.GEOSEqualsExact_r(Geos.current_handle_pointer, ptr, other.ptr, 0.5 * 10 ** -decimal))
    end
    alias equals_almost? eql_almost?
    alias almost_equals? eql_almost?

    def empty?
      bool_result(FFIGeos.GEOSisEmpty_r(Geos.current_handle_pointer, ptr))
    end

    def valid?
      bool_result(FFIGeos.GEOSisValid_r(Geos.current_handle_pointer, ptr))
    end

    # Returns a String describing whether or not the Geometry is valid.
    def valid_reason
      FFIGeos.GEOSisValidReason_r(Geos.current_handle_pointer, ptr)
    end

    # Returns a Hash containing the following structure on invalid geometries:
    #
    #   {
    #     detail: "String explaining the problem",
    #     location: Geos::Point # centered on the problem
    #   }
    #
    # If the Geometry is valid, returns nil.
    def valid_detail(flags = 0)
      detail = FFI::MemoryPointer.new(:pointer)
      location = FFI::MemoryPointer.new(:pointer)
      valid = bool_result(
        FFIGeos.GEOSisValidDetail_r(Geos.current_handle_pointer, ptr, flags, detail, location)
      )

      return if valid

      {
        detail: detail.read_pointer.read_string,
        location: cast_geometry_ptr(location.read_pointer, srid_copy: srid)
      }
    end

    def simple?
      bool_result(FFIGeos.GEOSisSimple_r(Geos.current_handle_pointer, ptr))
    end

    def ring?
      bool_result(FFIGeos.GEOSisRing_r(Geos.current_handle_pointer, ptr))
    end

    def has_z?
      bool_result(FFIGeos.GEOSHasZ_r(Geos.current_handle_pointer, ptr))
    end

    # GEOS versions prior to 3.3.0 didn't handle exceptions and can crash on
    # bad input.
    if FFIGeos.respond_to?(:GEOSProject_r) && Geos::GEOS_VERSION >= '3.3.0'
      def project(geom, normalized = false)
        raise TypeError, 'Expected Geos::Point type' unless geom.is_a?(Geos::Point)

        if normalized
          FFIGeos.GEOSProjectNormalized_r(Geos.current_handle_pointer, ptr, geom.ptr)
        else
          FFIGeos.GEOSProject_r(Geos.current_handle_pointer, ptr, geom.ptr)
        end
      end

      def project_normalized(geom)
        project(geom, true)
      end
    end

    def interpolate(d, normalized = false)
      ret = if normalized
        FFIGeos.GEOSInterpolateNormalized_r(Geos.current_handle_pointer, ptr, d)
      else
        FFIGeos.GEOSInterpolate_r(Geos.current_handle_pointer, ptr, d)
      end

      cast_geometry_ptr(ret, srid_copy: srid)
    end

    def interpolate_normalized(d)
      interpolate(d, true)
    end

    def start_point
      cast_geometry_ptr(FFIGeos.GEOSGeomGetStartPoint_r(Geos.current_handle_pointer, ptr), srid_copy: srid)
    end

    def end_point
      cast_geometry_ptr(FFIGeos.GEOSGeomGetEndPoint_r(Geos.current_handle_pointer, ptr), srid_copy: srid)
    end

    def area
      return 0 if empty?

      double_ptr = FFI::MemoryPointer.new(:double)
      FFIGeos.GEOSArea_r(Geos.current_handle_pointer, ptr, double_ptr)
      double_ptr.read_double
    end

    def length
      return 0 if empty?

      double_ptr = FFI::MemoryPointer.new(:double)
      FFIGeos.GEOSLength_r(Geos.current_handle_pointer, ptr, double_ptr)
      double_ptr.read_double
    end

    def distance(geom)
      check_geometry(geom)
      double_ptr = FFI::MemoryPointer.new(:double)
      FFIGeos.GEOSDistance_r(Geos.current_handle_pointer, ptr, geom.ptr, double_ptr)
      double_ptr.read_double
    end

    def hausdorff_distance(geom, densify_frac = nil)
      check_geometry(geom)

      double_ptr = FFI::MemoryPointer.new(:double)

      if densify_frac
        FFIGeos.GEOSHausdorffDistanceDensify_r(Geos.current_handle_pointer, ptr, geom.ptr, densify_frac, double_ptr)
      else
        FFIGeos.GEOSHausdorffDistance_r(Geos.current_handle_pointer, ptr, geom.ptr, double_ptr)
      end

      double_ptr.read_double
    end

    if FFIGeos.respond_to?(:GEOSNearestPoints_r)
      # Available in GEOS 3.4+.
      def nearest_points(geom)
        check_geometry(geom)
        nearest_points_ptr = FFIGeos.GEOSNearestPoints_r(Geos.current_handle_pointer, ptr, geom.ptr)

        return CoordinateSequence.new(nearest_points_ptr) unless nearest_points_ptr.null?
      end
    end

    def snap(geom, tolerance)
      check_geometry(geom)
      cast_geometry_ptr(FFIGeos.GEOSSnap_r(Geos.current_handle_pointer, ptr, geom.ptr, tolerance), srid_copy: pick_srid_from_geoms(srid, geom.srid))
    end
    alias snap_to snap

    def shared_paths(geom)
      check_geometry(geom)
      cast_geometry_ptr(FFIGeos.GEOSSharedPaths_r(Geos.current_handle_pointer, ptr, geom.ptr), srid_copy: pick_srid_from_geoms(srid, geom.srid)).to_a
    end

    # Returns a Hash with the following structure:
    #
    #   {
    #     rings: [ ... ],
    #     cuts: [ ... ],
    #     dangles: [ ... ],
    #     invalid_rings: [ ... ]
    #   }
    def polygonize_full
      cuts = FFI::MemoryPointer.new(:pointer)
      dangles = FFI::MemoryPointer.new(:pointer)
      invalid_rings = FFI::MemoryPointer.new(:pointer)

      rings = cast_geometry_ptr(FFIGeos.GEOSPolygonize_full_r(Geos.current_handle_pointer, ptr, cuts, dangles, invalid_rings), srid_copy: srid)

      cuts = cast_geometry_ptr(cuts.read_pointer, srid_copy: srid)
      dangles = cast_geometry_ptr(dangles.read_pointer, srid_copy: srid)
      invalid_rings = cast_geometry_ptr(invalid_rings.read_pointer, srid_copy: srid)

      {
        rings: rings.to_a,
        cuts: cuts.to_a,
        dangles: dangles.to_a,
        invalid_rings: invalid_rings.to_a
      }
    end

    def polygonize
      ary = FFI::MemoryPointer.new(:pointer)
      ary.write_array_of_pointer([ ptr ])

      cast_geometry_ptr(FFIGeos.GEOSPolygonize_r(Geos.current_handle_pointer, ary, 1), srid_copy: srid).to_a
    end

    def polygonize_cut_edges
      ary = FFI::MemoryPointer.new(:pointer)
      ary.write_array_of_pointer([ ptr ])

      cast_geometry_ptr(FFIGeos.GEOSPolygonizer_getCutEdges_r(Geos.current_handle_pointer, ary, 1), srid_copy: srid).to_a
    end

    if FFIGeos.respond_to?(:GEOSDelaunayTriangulation_r)
      # :call-seq:
      #   delaunay_triangulation(options = {})
      #   delaunay_triangulation(tolerance, options = {})
      #
      #  Options:
      #
      #  * :tolerance
      #  * :only_edges
      def delaunay_triangulation(*args)
        options = extract_options!(args)

        tolerance = args.first || options[:tolerance] || 0.0
        only_edges = bool_to_int(options[:only_edges])

        cast_geometry_ptr(FFIGeos.GEOSDelaunayTriangulation_r(Geos.current_handle_pointer, ptr, tolerance, only_edges))
      end
    end

    if FFIGeos.respond_to?(:GEOSVoronoiDiagram_r)
      # Available in GEOS 3.5.0+
      #
      # :call-seq:
      #   voronoi_diagram(options = {})
      #   voronoi_diagram(tolerance, options = {})
      #
      #  Options:
      #
      #  * :tolerance
      #  * :envelope
      #  * :only_edges
      def voronoi_diagram(*args)
        options = extract_options!(args)

        tolerance = args.first || options[:tolerance] || 0.0

        envelope_ptr = if options[:envelope]
          check_geometry(options[:envelope])
          options[:envelope].ptr
        end

        only_edges = bool_to_int(options[:only_edges])

        cast_geometry_ptr(FFIGeos.GEOSVoronoiDiagram_r(Geos.current_handle_pointer, ptr, envelope_ptr, tolerance, only_edges))
      end
    end

    def to_prepared
      Geos::PreparedGeometry.new(self)
    end

    def to_s
      writer = WktWriter.new
      wkt = writer.write(self)
      wkt = "#{wkt[0...120]} ... " if wkt.length > 120

      "#<Geos::#{geom_type}: #{wkt}>"
    end

    if FFIGeos.respond_to?(:GEOSGeom_getPrecision_r)
      def precision
        FFIGeos.GEOSGeom_getPrecision_r(Geos.current_handle_pointer, ptr)
      end
    end

    if FFIGeos.respond_to?(:GEOSGeom_setPrecision_r)
      def with_precision(grid_size, options = {})
        options = {
          no_topology: false,
          keep_collapsed: false
        }.merge(options)

        flags = options.reduce(0) do |memo, (key, value)|
          memo |= Geos::PrecisionOptions[key] if value
          memo
        end

        cast_geometry_ptr(FFIGeos.GEOSGeom_setPrecision_r(Geos.current_handle_pointer, ptr, grid_size, flags))
      end
    end

    if FFIGeos.respond_to?(:GEOSMinimumRotatedRectangle_r)
      def minimum_rotated_rectangle
        cast_geometry_ptr(FFIGeos.GEOSMinimumRotatedRectangle_r(Geos.current_handle_pointer, ptr))
      end
    end

    if FFIGeos.respond_to?(:GEOSMinimumClearance_r)
      def minimum_clearance
        double_ptr = FFI::MemoryPointer.new(:double)
        FFIGeos.GEOSMinimumClearance_r(Geos.current_handle_pointer, ptr, double_ptr)
        double_ptr.read_double
      end
    end

    if FFIGeos.respond_to?(:GEOSMinimumClearanceLine_r)
      def minimum_clearance_line
        cast_geometry_ptr(FFIGeos.GEOSMinimumClearanceLine_r(Geos.current_handle_pointer, ptr))
      end
    end

    if FFIGeos.respond_to?(:GEOSMinimumWidth_r)
      def minimum_width
        cast_geometry_ptr(FFIGeos.GEOSMinimumWidth_r(Geos.current_handle_pointer, ptr))
      end
    end

    if FFIGeos.respond_to?(:GEOSReverse_r)
      def reverse
        cast_geometry_ptr(FFIGeos.GEOSReverse_r(Geos.current_handle_pointer, ptr))
      end
    end

    if FFIGeos.respond_to?(:GEOSFrechetDistance_r)
      def frechet_distance(geom, densify_frac = nil)
        check_geometry(geom)

        double_ptr = FFI::MemoryPointer.new(:double)

        if densify_frac
          FFIGeos.GEOSFrechetDistanceDensify_r(Geos.current_handle_pointer, ptr, geom.ptr, densify_frac, double_ptr)
        else
          FFIGeos.GEOSFrechetDistance_r(Geos.current_handle_pointer, ptr, geom.ptr, double_ptr)
        end

        double_ptr.read_double
      end
    end
  end
end
