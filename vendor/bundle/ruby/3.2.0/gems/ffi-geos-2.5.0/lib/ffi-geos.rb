# frozen_string_literal: true

require 'ffi'
require 'rbconfig'
require 'ffi-geos/version'

module Geos
  GEOS_BASE = File.join(File.dirname(__FILE__), 'ffi-geos')

  autoload :WktReader,
    File.join(GEOS_BASE, 'wkt_reader')
  autoload :WktWriter,
    File.join(GEOS_BASE, 'wkt_writer')
  autoload :WkbReader,
    File.join(GEOS_BASE, 'wkb_reader')
  autoload :WkbWriter,
    File.join(GEOS_BASE, 'wkb_writer')
  autoload :GeoJSONReader,
    File.join(GEOS_BASE, 'geojson_reader')
  autoload :GeoJSONWriter,
    File.join(GEOS_BASE, 'geojson_writer')
  autoload :CoordinateSequence,
    File.join(GEOS_BASE, 'coordinate_sequence')
  autoload :Geometry,
    File.join(GEOS_BASE, 'geometry')
  autoload :PreparedGeometry,
    File.join(GEOS_BASE, 'prepared_geometry')
  autoload :GeometryCollection,
    File.join(GEOS_BASE, 'geometry_collection')
  autoload :LineString,
    File.join(GEOS_BASE, 'line_string')
  autoload :LinearRing,
    File.join(GEOS_BASE, 'linear_ring')
  autoload :MultiLineString,
    File.join(GEOS_BASE, 'multi_line_string')
  autoload :MultiPoint,
    File.join(GEOS_BASE, 'multi_point')
  autoload :MultiPolygon,
    File.join(GEOS_BASE, 'multi_polygon')
  autoload :Polygon,
    File.join(GEOS_BASE, 'polygon')
  autoload :Point,
    File.join(GEOS_BASE, 'point')
  autoload :STRtree,
    File.join(GEOS_BASE, 'strtree')
  autoload :BufferParams,
    File.join(GEOS_BASE, 'buffer_params')
  autoload :Tools,
    File.join(GEOS_BASE, 'tools')
  autoload :Utils,
    File.join(GEOS_BASE, 'utils')
  autoload :Interrupt,
    File.join(GEOS_BASE, 'interrupt')

  module FFIGeos
    def self.search_paths
      @search_paths ||=
        if ENV['GEOS_LIBRARY_PATH']
          [ENV['GEOS_LIBRARY_PATH']]
        elsif FFI::Platform::IS_WINDOWS
          ENV['PATH'].split(File::PATH_SEPARATOR)
        else
          [
            '/usr/local/{lib64,lib}',
            '/opt/local/{lib64,lib}',
            '/usr/{lib64,lib}',
            '/opt/homebrew/lib',
            '/usr/lib/{x86_64,i386,aarch64}-linux-gnu'
          ]
        end
    end

    def self.find_lib(lib)
      if ENV['GEOS_LIBRARY_PATH'] && File.file?(ENV['GEOS_LIBRARY_PATH'])
        ENV['GEOS_LIBRARY_PATH']
      else
        Dir.glob(search_paths.map do |path|
          File.expand_path(File.join(path, "#{lib}.#{FFI::Platform::LIBSUFFIX}{,.?}"))
        end).first
      end
    end

    def self.geos_library_path
      @geos_library_path ||=
        # On MingW the libraries have version numbers
        find_lib('{lib,}geos_c{,-?}')
    end

    # For backwards compatibility with older ffi-geos versions where this
    # used to return an Array.
    def self.geos_library_paths
      [geos_library_path]
    end

    extend ::FFI::Library

    Geos::DimensionTypes = enum(:dimension_type, [
      :dontcare, -3,
      :non_empty, -2,
      :empty, -1,
      :point, 0,
      :curve, 1,
      :surface, 2
    ])

    Geos::ByteOrders = enum(:byte_order, [
      :xdr, 0, # Big Endian
      :ndr, 1 # Little Endian
    ])

    Geos::Flavors = enum(:flavor, [
      :extended, 1,
      :iso, 2
    ])

    Geos::BufferCapStyles = enum(:buffer_cap_style, [
      :round, 1,
      :flat, 2,
      :square, 3
    ])

    Geos::BufferJoinStyles = enum(:buffer_join_style, [
      :round, 1,
      :mitre, 2,
      :bevel, 3
    ])

    Geos::ValidFlags = enum(:valid_flag, [
      :allow_selftouching_ring_forming_hole, 1
    ])

    Geos::RelateBoundaryNodeRules = enum(:relate_boundary_node_rule, [
      :mod2, 1,
      :ogc, 1,
      :endpoint, 2,
      :multivalent_endpoint, 3,
      :monovalent_endpoint, 4
    ])

    Geos::GeometryTypes = enum(:geometry_type, [
      :point, 0,
      :line_string, 1,
      :linear_ring, 2,
      :polygon, 3,
      :multi_point, 4,
      :multi_line_string, 5,
      :multi_polygon, 6,
      :geometry_collection, 7
    ])

    Geos::PrecisionOptions = enum(:precision_option, [
      :no_topology, 1 << 0,
      :keep_collapsed, 1 << 1
    ])

    Geos::PolygonHullSimplifyModes = enum(:polygon_hull_simplify_mode, [
      :vertex_ratio, 1,
      :area_ratio, 2
    ])

    FFI_LAYOUT = {
      #### Utility functions ####

      # Initialization and cleanup

      # deprecated in GEOS 3.5.0+
      initGEOS_r: [
        :pointer,

        # notice callback
        callback([:string, :string], :void),

        # error callback
        callback([:string, :string], :void)
      ],

      finishGEOS_r: [
        # void, *handle
        :void, :pointer
      ],
      # / deprecated in GEOS 3.5.0+

      # GEOS 3.5.0+
      GEOS_init_r: [:pointer],

      GEOSContext_setNoticeMessageHandler_r: [
        # void, *handle, callback, *void
        :void, :pointer, callback([:string, :string], :void), :pointer
      ],

      GEOSContext_setErrorMessageHandler_r: [
        # void, *handle, callback, *void
        :void, :pointer, callback([:string, :string], :void), :pointer
      ],

      GEOS_finish_r: [
        # void, *handle
        :void, :pointer
      ],
      # / GEOS 3.5.0+

      GEOS_interruptRegisterCallback: [
        :pointer,
        callback([], :void)
      ],

      GEOS_interruptRequest: [
        :void
      ],

      GEOS_interruptCancel: [
        :void
      ],

      GEOSversion: [
        :string
      ],

      GEOSjtsport: [
        :string
      ],

      GEOSPolygonize_r: [
        # *geom, *handle, **geoms, ngeoms
        :pointer, :pointer, :pointer, :uint
      ],

      GEOSPolygonize_valid_r: [
        # *geom, *handle, **geoms, ngeoms
        :pointer, :pointer, :pointer, :uint
      ],

      GEOSBuildArea_r: [
        # *geom, *handle, *geom
        :pointer, :pointer, :pointer
      ],

      GEOSMakeValid_r: [
        # *geom, *handle, *geom
        :pointer, :pointer, :pointer
      ],

      GEOSPolygonizer_getCutEdges_r: [
        # *geom, *handle, **geoms, ngeoms
        :pointer, :pointer, :pointer, :uint
      ],

      GEOSPolygonize_full_r: [
        # *geom, *handle, *geom, **cuts, **dangles, **invalid
        :pointer, :pointer, :pointer, :pointer, :pointer, :pointer
      ],

      GEOSGeom_createPoint_r: [
        # *geom, *handle, *coord_seq
        :pointer, :pointer, :pointer
      ],

      GEOSGeom_createEmptyPoint_r: [
        # *geom, *handle
        :pointer, :pointer
      ],

      GEOSGeom_createEmptyLineString_r: [
        # *geom, *handle
        :pointer, :pointer
      ],

      GEOSGeom_createLinearRing_r: [
        # *geom, *handle, *coord_seq
        :pointer, :pointer, :pointer
      ],

      GEOSGeom_createLineString_r: [
        # *geom, *handle, *coord_seq
        :pointer, :pointer, :pointer
      ],

      GEOSGeom_createPolygon_r: [
        # *geom, *handle, *geom, **holes, nholes
        :pointer, :pointer, :pointer, :pointer, :uint
      ],

      GEOSGeom_createEmptyPolygon_r: [
        # *geom, *handle
        :pointer, :pointer
      ],

      GEOSGeom_createCollection_r: [
        # *geom, *handle, type, **geoms, ngeoms
        :pointer, :pointer, :geometry_type, :pointer, :uint
      ],

      GEOSGeom_createEmptyCollection_r: [
        # *geom, *handle, type
        :pointer, :pointer, :geometry_type
      ],
      #### /Utility functions ####

      #### CoordinateSequence functions ####
      GEOSCoordSeq_create_r: [
        # *coord_seq, *handle, size, dims
        :pointer, :pointer, :uint, :uint
      ],

      GEOSCoordSeq_destroy_r: [
        # void, *handle, *coord_seq
        :void, :pointer, :pointer
      ],

      GEOSCoordSeq_clone_r: [
        # *coord_seq, *handle, *coord_seq
        :pointer, :pointer, :pointer
      ],

      GEOSCoordSeq_setX_r: [
        # 0 on exception, *handle, *coord_seq, idx, val
        :int, :pointer, :pointer, :uint, :double
      ],

      GEOSCoordSeq_setY_r: [
        # 0 on exception, *handle, *coord_seq, idx, val
        :int, :pointer, :pointer, :uint, :double
      ],

      GEOSCoordSeq_setZ_r: [
        # 0 on exception, *handle, *coord_seq, idx, val
        :int, :pointer, :pointer, :uint, :double
      ],

      GEOSCoordSeq_setOrdinate_r: [
        # 0 on exception, *handle, *coord_seq, idx, dim, val
        :int, :pointer, :pointer, :uint, :uint, :double
      ],

      GEOSCoordSeq_getX_r: [
        # 0 on exception, *handle, *coord_seq, idx, (double *) val
        :int, :pointer, :pointer, :uint, :pointer
      ],

      GEOSCoordSeq_getY_r: [
        # 0 on exception, *handle, *coord_seq, idx, (double *) val
        :int, :pointer, :pointer, :uint, :pointer
      ],

      GEOSCoordSeq_getZ_r: [
        # 0 on exception, *handle, *coord_seq, idx, (double *) val
        :int, :pointer, :pointer, :uint, :pointer
      ],

      GEOSCoordSeq_getOrdinate_r: [
        # 0 on exception, *handle, *coord_seq, idx, dim, (double *) val
        :int, :pointer, :pointer, :uint, :uint, :pointer
      ],

      GEOSCoordSeq_getSize_r: [
        # 0 on exception, *handle, *coord_seq, (uint *) size
        :int, :pointer, :pointer, :pointer
      ],

      GEOSCoordSeq_getDimensions_r: [
        # 0 on exception, *handle, *coord_seq, (uint *) size
        :int, :pointer, :pointer, :pointer
      ],

      GEOSCoordSeq_isCCW_r: [
        # 0 on exception, *handle, *coord_seq, (char *) value
        :int, :pointer, :pointer, :pointer
      ],
      #### /CoordinateSequence functions ####

      #### Geometry functions ####
      GEOSGeom_destroy_r: [
        # void, *handle, *geom
        :void, :pointer, :pointer
      ],

      GEOSGeom_clone_r: [
        # *geom, *handle, *geom
        :pointer, :pointer, :pointer
      ],

      GEOSGeomTypeId_r: [
        # type, *handle, *geom
        :int, :pointer, :pointer
      ],

      GEOSGeomType_r: [
        # type, *handle, *geom
        :string, :pointer, :pointer
      ],

      GEOSGetSRID_r: [
        # srid, *handle, *geom
        :int, :pointer, :pointer
      ],

      GEOSSetSRID_r: [
        # void, *handle, *geom, srid
        :void, :pointer, :pointer, :int
      ],

      GEOSGeom_getDimensions_r: [
        # dims, *handle, *geom
        :int, :pointer, :pointer
      ],

      GEOSGetNumGeometries_r: [
        # ngeoms, *handle, *geom
        :int, :pointer, :pointer
      ],

      GEOSGetNumCoordinates_r: [
        # numcoords, *handle, *geom
        :int, :pointer, :pointer
      ],

      GEOSGeom_getCoordSeq_r: [
        # *coord_seq, *handle, *geom
        :pointer, :pointer, :pointer
      ],

      GEOSIntersection_r: [
        # *geom, *handle, *geom_a, *geom_b
        :pointer, :pointer, :pointer, :pointer
      ],

      GEOSIntersectionPrec_r: [
        # *geom, *handle, *geom_a, *geom_b, precision
        :pointer, :pointer, :pointer, :pointer, :double
      ],

      GEOSBufferWithParams_r: [
        # *geom, *handle, *geom, *params, width
        :pointer, :pointer, :pointer, :pointer, :double
      ],

      GEOSBuffer_r: [
        # *geom, *handle, *geom, width, quad_segs
        :pointer, :pointer, :pointer, :double, :int
      ],

      GEOSBufferWithStyle_r: [
        # *geom, *handle, *geom, width, quad_segs, buffer_cap_style, buffer_join_style, mitre_limit
        :pointer, :pointer, :pointer, :double, :int, :buffer_cap_style, :buffer_join_style, :double
      ],

      GEOSDensify_r: [
        # *geom, *handle, *geom, tolerence
        :pointer, :pointer, :pointer, :double
      ],

      # Deprecated in GEOS 3.3.0.
      GEOSSingleSidedBuffer_r: [
        # *geom, *handle, *geom, width, quad_segs, buffer_join_style, mitre_limit, is_left
        :pointer, :pointer, :pointer, :double, :int, :buffer_join_style, :double, :int
      ],

      GEOSOffsetCurve_r: [
        # *geom, *handle, *geom, width, quad_segs, buffer_join_style, mitre_limit
        :pointer, :pointer, :pointer, :double, :int, :buffer_join_style, :double
      ],

      GEOSConvexHull_r: [
        # *geom, *handle, *geom
        :pointer, :pointer, :pointer
      ],

      GEOSConcaveHull_r: [
        # *geom, *handle, *geom, ratio, allow_holes
        :pointer, :pointer, :pointer, :double, :uint
      ],

      GEOSConcaveHullByLength_r: [
        # *geom, *handle, *geom, length, allow_holes
        :pointer, :pointer, :pointer, :double, :uint
      ],

      GEOSPolygonHullSimplify_r: [
        # *geom, *handle, *geom, is_outer, vertex_num_fraction
        :pointer, :pointer, :pointer, :uint, :double
      ],

      GEOSPolygonHullSimplifyMode_r: [
        # *geom, *handle, *geom, is_outer, parameter_mode, parameter
        :pointer, :pointer, :pointer, :uint, :uint, :double
      ],

      GEOSDifference_r: [
        # *geom, *handle, *geom_a, *geom_b
        :pointer, :pointer, :pointer, :pointer
      ],

      GEOSDifferencePrec_r: [
        # *geom, *handle, *geom_a, *geom_b, precision
        :pointer, :pointer, :pointer, :pointer, :double
      ],

      GEOSSymDifference_r: [
        # *geom, *handle, *geom_a, *geom_b
        :pointer, :pointer, :pointer, :pointer
      ],

      GEOSSymDifferencePrec_r: [
        # *geom, *handle, *geom_a, *geom_b, precision
        :pointer, :pointer, :pointer, :pointer, :double
      ],

      GEOSBoundary_r: [
        # *geom, *handle, *geom
        :pointer, :pointer, :pointer
      ],

      GEOSUnion_r: [
        # *geom, *handle, *geom_a, *geom_b
        :pointer, :pointer, :pointer, :pointer
      ],

      GEOSUnionPrec_r: [
        # *geom, *handle, *geom_a, *geom_b, precision
        :pointer, :pointer, :pointer, :pointer, :double
      ],

      GEOSCoverageUnion_r: [
        # *geom, *handle, *geom
        :pointer, :pointer, :pointer
      ],

      GEOSDisjointSubsetUnion_r: [
        # *geom, *handle, *geom
        :pointer, :pointer, :pointer
      ],

      GEOSUnaryUnion_r: [
        # *geom, *handle, *geom
        :pointer, :pointer, :pointer
      ],

      GEOSUnaryUnionPrec_r: [
        # *geom, *handle, *geom, precision
        :pointer, :pointer, :pointer, :double
      ],

      GEOSNode_r: [
        # *geom, *handle, *geom
        :pointer, :pointer, :pointer
      ],

      # Deprecated in GEOS 3.3.0. Use GEOSUnaryUnion_r instead.
      GEOSUnionCascaded_r: [
        # *geom, *handle, *geom
        :pointer, :pointer, :pointer
      ],

      GEOSPointOnSurface_r: [
        # *geom, *handle, *geom
        :pointer, :pointer, :pointer
      ],

      GEOSClipByRect_r: [
        # *geom, *handle, *geom, xmin, ymin, xmax, ymax
        :pointer, :pointer, :pointer, :double, :double, :double, :double
      ],

      GEOSGetCentroid_r: [
        # *geom, *handle, *geom
        :pointer, :pointer, :pointer
      ],

      GEOSHilbertCode_r: [
        # int, *handler, *geom, *extent, level, *code
        :int, :pointer, :pointer, :pointer, :uint, :pointer
      ],

      GEOSMinimumBoundingCircle_r: [
        # *geom, *handle, *geom, *double radius, **geom center
        :pointer, :pointer, :pointer, :pointer, :pointer
      ],

      GEOSEnvelope_r: [
        # *geom, *handle, *geom
        :pointer, :pointer, :pointer
      ],

      GEOSLineMerge_r: [
        # *geom, *handle, *geom
        :pointer, :pointer, :pointer
      ],

      GEOSLineMergeDirected_r: [
        # *geom, *handle, *geom
        :pointer, :pointer, :pointer
      ],

      GEOSLineSubstring_r: [
        # *geom, *handle, *geom, start_fraction, end_fraction
        :pointer, :pointer, :pointer, :double, :double
      ],

      GEOSGeom_getXMin_r: [
        # 0 on exception, *handle, (double *) value
        :int, :pointer, :pointer, :pointer
      ],

      GEOSGeom_getXMax_r: [
        # 0 on exception, *handle, (double *) value
        :int, :pointer, :pointer, :pointer
      ],

      GEOSGeom_getYMin_r: [
        # 0 on exception, *handle, (double *) value
        :int, :pointer, :pointer, :pointer
      ],

      GEOSGeom_getYMax_r: [
        # 0 on exception, *handle, (double *) value
        :int, :pointer, :pointer, :pointer
      ],

      GEOSSimplify_r: [
        # *geom, *handle, *geom, tolerance
        :pointer, :pointer, :pointer, :double
      ],

      GEOSTopologyPreserveSimplify_r: [
        # *geom, *handle, *geom, tolerance
        :pointer, :pointer, :pointer, :double
      ],

      GEOSGeom_extractUniquePoints_r: [
        # *geom, *handle, *geom
        :pointer, :pointer, :pointer
      ],

      GEOSSharedPaths_r: [
        # *geom, *handle, *geom_a, *geom_b
        :pointer, :pointer, :pointer, :pointer
      ],

      GEOSSnap_r: [
        # *geom, *handle, *geom_a, *geom_b, tolerance
        :pointer, :pointer, :pointer, :pointer, :double
      ],

      GEOSDelaunayTriangulation_r: [
        # *geom, *handle, *geom, tolerance, only_edges
        :pointer, :pointer, :pointer, :double, :int
      ],

      GEOSConstrainedDelaunayTriangulation_r: [
        # *geom, *handle, *geom
        :pointer, :pointer, :pointer
      ],

      GEOSVoronoiDiagram_r: [
        # *geom, *handle, *geom, *envelope, tolerance, only_edges
        :pointer, :pointer, :pointer, :pointer, :double, :int
      ],

      GEOSRelate_r: [
        # string, *handle, *geom_a, *geom_b
        :string, :pointer, :pointer, :pointer
      ],

      GEOSRelatePatternMatch_r: [
        # (2 on exception, 1 on true, 2 on false), *handle, pattern_a, pattern_b
        :char, :pointer, :string, :string
      ],

      GEOSRelatePattern_r: [
        # (2 on exception, 1 on true, 2 on false), *handle, *geom_a, *geom_b, pattern
        :char, :pointer, :pointer, :pointer, :string
      ],

      GEOSRelateBoundaryNodeRule_r: [
        # string, *handle, *geom_a, *geom_b, bnr
        :string, :pointer, :pointer, :pointer, :relate_boundary_node_rule
      ],

      GEOSDisjoint_r: [
        # (2 on exception, 1 on true, 2 on false), *handle, *geom_a, *geom_b
        :char, :pointer, :pointer, :pointer
      ],

      GEOSTouches_r: [
        # (2 on exception, 1 on true, 2 on false), *handle, *geom_a, *geom_b
        :char, :pointer, :pointer, :pointer
      ],

      GEOSIntersects_r: [
        # (2 on exception, 1 on true, 2 on false), *handle, *geom_a, *geom_b
        :char, :pointer, :pointer, :pointer
      ],

      GEOSCrosses_r: [
        # (2 on exception, 1 on true, 2 on false), *handle, *geom_a, *geom_b
        :char, :pointer, :pointer, :pointer
      ],

      GEOSWithin_r: [
        # (2 on exception, 1 on true, 2 on false), *handle, *geom_a, *geom_b
        :char, :pointer, :pointer, :pointer
      ],

      GEOSContains_r: [
        # (2 on exception, 1 on true, 2 on false), *handle, *geom_a, *geom_b
        :char, :pointer, :pointer, :pointer
      ],

      GEOSOverlaps_r: [
        # (2 on exception, 1 on true, 2 on false), *handle, *geom_a, *geom_b
        :char, :pointer, :pointer, :pointer
      ],

      GEOSCovers_r: [
        # (2 on exception, 1 on true, 2 on false), *handle, *geom_a, *geom_b
        :char, :pointer, :pointer, :pointer
      ],

      GEOSCoveredBy_r: [
        # (2 on exception, 1 on true, 2 on false), *handle, *geom_a, *geom_b
        :char, :pointer, :pointer, :pointer
      ],

      GEOSEquals_r: [
        # (2 on exception, 1 on true, 2 on false), *handle, *geom_a, *geom_b
        :char, :pointer, :pointer, :pointer
      ],

      GEOSEqualsExact_r: [
        # (2 on exception, 1 on true, 2 on false), *handle, *geom_a, *geom_b
        :char, :pointer, :pointer, :pointer, :double
      ],

      GEOSEqualsIdentical_r: [
        # (2 on exception, 1 on true, 2 on false), *handle, *geom_a, *geom_b
        :char, :pointer, :pointer, :pointer
      ],

      GEOSisEmpty_r: [
        # (2 on exception, 1 on true, 2 on false), *handle, *geom
        :char, :pointer, :pointer
      ],

      GEOSisValid_r: [
        # (2 on exception, 1 on true, 2 on false), *handle, *geom
        :char, :pointer, :pointer
      ],

      GEOSisValidReason_r: [
        # reason, *handle, *geom
        :string, :pointer, :pointer
      ],

      GEOSisValidDetail_r: [
        # (2 on exception, 1 on true, 2 on false), *handle, *geom, flags, (string**) reasons, **geoms
        :char, :pointer, :pointer, :int, :pointer, :pointer
      ],

      GEOSisSimple_r: [
        # (2 on exception, 1 on true, 2 on false), *handle, *geom
        :char, :pointer, :pointer
      ],

      GEOSisRing_r: [
        # (2 on exception, 1 on true, 2 on false), *handle, *geom
        :char, :pointer, :pointer
      ],

      GEOSHasZ_r: [
        # (2 on exception, 1 on true, 2 on false), *handle, *geom
        :char, :pointer, :pointer
      ],

      GEOSHasM_r: [
        # (2 on exception, 1 on true, 2 on false), *handle, *geom
        :char, :pointer, :pointer
      ],

      GEOSisClosed_r: [
        # (2 on exception, 1 on true, 2 on false), *handle, *geom
        :char, :pointer, :pointer
      ],

      GEOSArea_r: [
        # (0 on exception, 1 otherwise), *handle, *geom, (double *) area
        :int, :pointer, :pointer, :pointer
      ],

      GEOSLength_r: [
        # (0 on exception, 1 otherwise), *handle, *geom, (double *) length
        :int, :pointer, :pointer, :pointer
      ],

      GEOSDistance_r: [
        # (0 on exception, 1 otherwise), *handle, *geom_a, *geom_b, (double *) distance
        :int, :pointer, :pointer, :pointer, :pointer
      ],

      GEOSDistanceIndexed_r: [
        # (0 on exception, 1 otherwise), *handle, *geom_a, *geom_b, (double *) distance
        :int, :pointer, :pointer, :pointer, :pointer
      ],

      GEOSDistanceWithin_r: [
        # (0 on exception, 1 otherwise), *handle, *geom_a, *geom_b, double distance
        :char, :pointer, :pointer, :pointer, :double
      ],

      GEOSHausdorffDistance_r: [
        # (0 on exception, 1 otherwise), *handle, *geom_a, *geom_b, (double *) distance
        :int, :pointer, :pointer, :pointer, :pointer
      ],

      GEOSHausdorffDistanceDensify_r: [
        # (0 on exception, 1 otherwise), *handle, *geom_a, *geom_b, densifyFrac, (double *) distance
        :int, :pointer, :pointer, :pointer, :double, :pointer
      ],

      GEOSNearestPoints_r: [
        # (NULL on exception, pointer to CoordinateSequence otherwise), *handle, *geom, *geom
        :pointer, :pointer, :pointer, :pointer
      ],

      GEOSGetGeometryN_r: [
        # *geom, *handle, *geom, n
        :pointer, :pointer, :pointer, :int
      ],

      GEOSGetNumInteriorRings_r: [
        # rings, *handle, *geom
        :int, :pointer, :pointer
      ],

      GEOSNormalize_r: [
        # -1 on exception, *handle, *geom
        :int, :pointer, :pointer
      ],

      GEOSOrientPolygons_r: [
        # -1 on exception, *handle, *geom, exterior_cw
        :int, :pointer, :pointer, :int
      ],

      GEOSGetInteriorRingN_r: [
        # *geom, *handle, *geom, n
        :pointer, :pointer, :pointer, :int
      ],

      GEOSGetExteriorRing_r: [
        # *geom, *handle, *geom
        :pointer, :pointer, :pointer
      ],

      GEOSGeomGetNumPoints_r: [
        # numpoints, *handle, *geom
        :int, :pointer, :pointer
      ],

      GEOSGeomGetX_r: [
        # -1 on exception, *handle, *geom, *point
        :int, :pointer, :pointer, :pointer
      ],

      GEOSGeomGetY_r: [
        # -1 on exception, *handle, *geom, *point
        :int, :pointer, :pointer, :pointer
      ],

      GEOSGeomGetZ_r: [
        # -1 on exception, *handle, *geom, *point
        :int, :pointer, :pointer, :pointer
      ],

      GEOSGeomGetM_r: [
        # -1 on exception, *handle, *geom, *point
        :int, :pointer, :pointer, :pointer
      ],

      GEOSGeomGetPointN_r: [
        # *point, *handle, *geom, n
        :pointer, :pointer, :pointer, :int
      ],

      GEOSGeomGetStartPoint_r: [
        # *point, *handle, *geom
        :pointer, :pointer, :pointer
      ],

      GEOSGeomGetEndPoint_r: [
        # *point, *handle, *geom
        :pointer, :pointer, :pointer
      ],

      GEOSGeom_setPrecision_r: [
        # *geom, *hande, *geom, grid_size, int flags
        :pointer, :pointer, :pointer, :double, :int
      ],

      GEOSGeom_getPrecision_r: [
        # precision, *hande, *geom
        :double, :pointer, :pointer
      ],

      GEOSConcaveHullOfPolygons_r: [
        # *geom, *handle, *geom, length_ratio, tight, allow_holes
        :pointer, :pointer, :pointer, :double, :uint, :uint
      ],

      GEOSMinimumRotatedRectangle_r: [
        # *geom, *handle, *geom
        :pointer, :pointer, :pointer
      ],

      GEOSMinimumClearance_r: [
        # 0 on success, *handle, *geom, *clearance
        :int, :pointer, :pointer, :pointer
      ],

      GEOSMinimumClearanceLine_r: [
        # *geom, *handle, *geom
        :pointer, :pointer, :pointer
      ],

      GEOSMaximumInscribedCircle_r: [
        # *geom, *handle, *geom, tolerance
        :pointer, :pointer, :pointer, :double
      ],

      GEOSLargestEmptyCircle_r: [
        # *geom, *handle, *geom, *geom, tolerance
        :pointer, :pointer, :pointer, :pointer, :double
      ],

      GEOSMinimumWidth_r: [
        # *geom, *handle, *geom
        :pointer, :pointer, :pointer
      ],

      GEOSReverse_r: [
        # *geom, *handle, *geom
        :pointer, :pointer, :pointer
      ],

      GEOSFrechetDistance_r: [
        # (0 on exception, 1 otherwise), *handle, *geom_a, *geom_b, (double *) distance
        :int, :pointer, :pointer, :pointer, :pointer
      ],

      GEOSFrechetDistanceDensify_r: [
        # (0 on exception, 1 otherwise), *handle, *geom_a, *geom_b, densifyFrac, (double *) distance
        :int, :pointer, :pointer, :pointer, :double, :pointer
      ],
      #### /Geometry functions ####

      #### STRtree functions ####
      GEOSSTRtree_create_r: [
        # *tree, *handle, node_capacity
        :pointer, :pointer, :size_t
      ],

      GEOSSTRtree_insert_r: [
        # void, *handle, *tree, *geom, *void
        :void, :pointer, :pointer, :pointer, :pointer
      ],

      GEOSSTRtree_query_r: [
        # void, *handle, *tree, *geom, void query_callback((void *) item, (void *) user_data), (void *) user_data
        :void, :pointer, :pointer, :pointer, callback([:pointer, :pointer], :void), :pointer
      ],

      GEOSSTRtree_iterate_r: [
        # void, *handle, *tree, void query_callback((void *) item, (void *) user_data), (void *) user_data
        :void, :pointer, :pointer, callback([:pointer, :pointer], :void), :pointer
      ],

      GEOSSTRtree_remove_r: [
        # bool, *handle, *tree, *geom, (void *) item
        :char, :pointer, :pointer, :pointer, :pointer
      ],

      GEOSSTRtree_destroy_r: [
        # void, *handle, *tree
        :void, :pointer, :pointer
      ],

      GEOSSTRtree_nearest_generic_r: [
        # *void, *handle, *tree, *item, *item_envelope, int distance_callback(*item_1, *item_2, *double, void *user_data), *user_data
        :pointer, :pointer, :pointer, :pointer, :pointer, callback([:pointer, :pointer, :pointer, :pointer], :int), :pointer
      ],
      #### /STRtree functions ####

      #### PreparedGeometry functions ####
      GEOSPrepare_r: [
        # *prepared, *handle, *geom
        :pointer, :pointer, :pointer
      ],

      GEOSPreparedGeom_destroy_r: [
        # void, *handle, *geom
        :void, :pointer, :pointer
      ],

      GEOSPreparedContains_r: [
        # (2 on exception, 1 on true, 0 on false), *handle, *prepared, *geom
        :char, :pointer, :pointer, :pointer
      ],

      GEOSPreparedContainsProperly_r: [
        # (2 on exception, 1 on true, 0 on false), *handle, *prepared, *geom
        :char, :pointer, :pointer, :pointer
      ],

      GEOSPreparedCoveredBy_r: [
        # (2 on exception, 1 on true, 0 on false), *handle, *prepared, *geom
        :char, :pointer, :pointer, :pointer
      ],

      GEOSPreparedCovers_r: [
        # (2 on exception, 1 on true, 0 on false), *handle, *prepared, *geom
        :char, :pointer, :pointer, :pointer
      ],

      GEOSPreparedCrosses_r: [
        # (2 on exception, 1 on true, 0 on false), *handle, *prepared, *geom
        :char, :pointer, :pointer, :pointer
      ],

      GEOSPreparedDisjoint_r: [
        # (2 on exception, 1 on true, 0 on false), *handle, *prepared, *geom
        :char, :pointer, :pointer, :pointer
      ],

      GEOSPreparedIntersects_r: [
        # (2 on exception, 1 on true, 0 on false), *handle, *prepared, *geom
        :char, :pointer, :pointer, :pointer
      ],

      GEOSPreparedOverlaps_r: [
        # (2 on exception, 1 on true, 0 on false), *handle, *prepared, *geom
        :char, :pointer, :pointer, :pointer
      ],

      GEOSPreparedTouches_r: [
        # (2 on exception, 1 on true, 0 on false), *handle, *prepared, *geom
        :char, :pointer, :pointer, :pointer
      ],

      GEOSPreparedWithin_r: [
        # (2 on exception, 1 on true, 0 on false), *handle, *prepared, *geom
        :char, :pointer, :pointer, :pointer
      ],

      GEOSPreparedDistance_r: [
        # (1 on success, 0 on failure), *handle, *prepared, *geom, *distance
        :int, :pointer, :pointer, :pointer, :pointer
      ],

      GEOSPreparedDistanceWithin_r: [
        # (1 on true, 0 on false), *handle, *prepared, *geom, max_distance
        :char, :pointer, :pointer, :pointer, :double
      ],

      GEOSPreparedNearestPoints_r: [
        # *coord_seq, *handle, *prepared, *geom
        :pointer, :pointer, :pointer, :pointer
      ],
      #### /PreparedGeometry functions ####

      #### WktReader functions ####
      GEOSWKTReader_create_r: [
        # *wktr, *handle
        :pointer, :pointer
      ],

      GEOSWKTReader_read_r: [
        # *geom, *handle, *wktr, string
        :pointer, :pointer, :pointer, :string
      ],

      GEOSWKTReader_destroy_r: [
        # void, *handle, *wktr
        :void, :pointer, :pointer
      ],
      #### /WktReader functions ###

      #### WktWriter functions ####
      GEOSWKTWriter_create_r: [
        # *wktw, *handle
        :pointer, :pointer
      ],

      GEOSWKTWriter_write_r: [
        # string, *handle, *wktw, *geom
        :string, :pointer, :pointer, :pointer
      ],

      GEOSWKTWriter_destroy_r: [
        # void, *handle, *wktw
        :void, :pointer, :pointer
      ],

      GEOSWKTWriter_setTrim_r: [
        # void, *handle, *wktw, bool
        :void, :pointer, :pointer, :char
      ],

      GEOSWKTWriter_setRoundingPrecision_r: [
        # void, *handle, *wktw, precision
        :void, :pointer, :pointer, :int
      ],

      GEOSWKTWriter_setOutputDimension_r: [
        # void, *handle, *wktw, dimensions
        :void, :pointer, :pointer, :int
      ],

      GEOSWKTWriter_getOutputDimension_r: [
        # dimensions, *handle, *wktw
        :int, :pointer, :pointer
      ],

      GEOSWKTWriter_setOld3D_r: [
        # void, *handle, *wktw, bool
        :void, :pointer, :pointer, :int
      ],
      #### /WktWriter functions ####

      #### WkbReader functions ####
      GEOSWKBReader_create_r: [
        # *wkbr, *handle
        :pointer, :pointer
      ],

      GEOSWKBReader_destroy_r: [
        # void, *handle, *wkbr
        :void, :pointer, :pointer
      ],

      GEOSWKBReader_read_r: [
        # *geom, *handle, *wkbr, (unsigned char *) string, size_t
        :pointer, :pointer, :pointer, :pointer, :size_t
      ],

      GEOSWKBReader_readHEX_r: [
        # *geom, *handle, *wkbr, string, size_t
        :pointer, :pointer, :pointer, :string, :size_t
      ],
      #### /WkbReader functions ####

      #### WkbWriter functions ####
      GEOSWKBWriter_create_r: [
        # *wkbw, *handle
        :pointer, :pointer
      ],

      GEOSWKBWriter_destroy_r: [
        # void, *handle, *wkbw
        :void, :pointer, :pointer
      ],

      GEOSWKBWriter_write_r: [
        # (unsigned char *) string, *handle, *wkbw, *geom, *size_t
        :pointer, :pointer, :pointer, :pointer, :pointer
      ],

      GEOSWKBWriter_writeHEX_r: [
        # (unsigned char *) string, *handle, *wkbw, *geom, *size_t
        :pointer, :pointer, :pointer, :pointer, :pointer
      ],

      GEOSWKBWriter_setOutputDimension_r: [
        # void, *handle, *wkbw, dimensions
        :void, :pointer, :pointer, :int
      ],

      GEOSWKBWriter_getOutputDimension_r: [
        # dimensions, *handle, *wkbw
        :int, :pointer, :pointer
      ],

      GEOSWKBWriter_getByteOrder_r: [
        # byte_order, *handle, *wkbw
        :byte_order, :pointer, :pointer
      ],

      GEOSWKBWriter_setByteOrder_r: [
        # void, *handle, *wkbw, byte_order
        :void, :pointer, :pointer, :byte_order
      ],

      GEOSWKBWriter_getIncludeSRID_r: [
        # bool, *handle, *geom
        :char, :pointer, :pointer
      ],

      GEOSWKBWriter_setIncludeSRID_r: [
        # void, *handle, *geom, bool
        :void, :pointer, :pointer, :char
      ],

      GEOSWKBWriter_getFlavor_r: [
        # flavor, *handle, *geom
        :flavor, :pointer, :pointer
      ],

      GEOSWKBWriter_setFlavor_r: [
        # void, *handle, *geom, flavor
        :void, :pointer, :pointer, :flavor
      ],
      #### /WkbWriter functions ####

      #### GeoJSONReader functions ####
      GEOSGeoJSONReader_create_r: [
        # *geojson_reader, *handle
        :pointer, :pointer
      ],

      GEOSGeoJSONReader_readGeometry_r: [
        # *geom, *handle, *geojson_reader, string
        :pointer, :pointer, :pointer, :string
      ],

      GEOSGeoJSONReader_destroy_r: [
        # void, *handle, *geojson_reader
        :void, :pointer, :pointer
      ],
      #### /GeoJSONReader functions ###

      #### GeoJSONWriter functions ####
      GEOSGeoJSONWriter_create_r: [
        # *geojson_writer, *handle
        :pointer, :pointer
      ],

      GEOSGeoJSONWriter_destroy_r: [
        # void, *handle, *geojson_writer
        :void, :pointer, :pointer
      ],

      GEOSGeoJSONWriter_writeGeometry_r: [
        # string, *handle, *geojson_writer, :geom, :indent
        :string, :pointer, :pointer, :pointer, :int
      ],
      #### /GeoJSONWriter functions ####

      #### Linearref functions ####
      GEOSProject_r: [
        # distance, *handle, *geom_a, *geom_b
        :double, :pointer, :pointer, :pointer
      ],

      GEOSProjectNormalized_r: [
        # distance, *handle, *geom_a, *geom_b
        :double, :pointer, :pointer, :pointer
      ],

      GEOSInterpolate_r: [
        # *geom, *handle, *geom, distance
        :pointer, :pointer, :pointer, :double
      ],

      GEOSInterpolateNormalized_r: [
        # *geom, *handle, *geom, distance
        :pointer, :pointer, :pointer, :double
      ],
      #### /Linearref functions ####

      #### BufferParams functions ####
      GEOSBufferParams_create_r: [
        # GEOSBufferParams*, *handle
        :pointer, :pointer
      ],

      GEOSBufferParams_destroy_r: [
        # void, *handle, *params
        :void, :pointer, :pointer
      ],

      GEOSBufferParams_setEndCapStyle_r: [
        # 0 on exception, *handle, *params, style
        :int, :pointer, :pointer, :buffer_cap_style
      ],

      GEOSBufferParams_setJoinStyle_r: [
        # 0 on exception, *handle, *params, style
        :int, :pointer, :pointer, :buffer_join_style
      ],

      GEOSBufferParams_setMitreLimit_r: [
        # 0 on exception, *handle, *params, mitre_limit
        :int, :pointer, :pointer, :double
      ],

      GEOSBufferParams_setQuadrantSegments_r: [
        # 0 on exception, *handle, *params, quad_segs
        :int, :pointer, :pointer, :int
      ],

      GEOSBufferParams_setSingleSided_r: [
        # 0 on exception, *handle, *params, bool
        :int, :pointer, :pointer, :int
      ],
      #### /BufferParams functions ####

      #### Algorithms ####
      # -1 if reaching P takes a counter-clockwise (left) turn
      # 1 if reaching P takes a clockwise (right) turn
      # 0 if P is collinear with A-B
      GEOSOrientationIndex_r: [
        # int, *handle, Ax, Ay, Bx, By, Px, Py
        :int, :pointer, :double, :double, :double, :double, :double, :double
      ]
      #### /Algorithms ####
    }.freeze

    begin
      ffi_lib(geos_library_path)

      FFI_LAYOUT.each do |func, ary|
        ret = ary.shift
        begin
          class_eval do
            attach_function(func, ary, ret)
          end
        rescue FFI::NotFoundError
          # that's okay
        end
      end

      # Checks to see if we actually have the GEOS library loaded.
      FFIGeos.GEOSversion
    rescue LoadError, NoMethodError
      raise LoadError, "Couldn't load the GEOS CAPI library."
    end
  end

  class Handle
    attr_reader :ptr

    if FFIGeos.respond_to?(:GEOS_init_r)
      def initialize
        @ptr = FFI::AutoPointer.new(FFIGeos.GEOS_init_r, self.class.method(:release))

        reset_notice_handler
        reset_error_handler
      end

      def self.release(ptr)
        FFIGeos.GEOS_finish_r(ptr)
      end

      def notice_handler=(method_or_block)
        @notice_handler = method_or_block
        FFIGeos.GEOSContext_setNoticeMessageHandler_r(@ptr, @notice_handler, nil)
      end

      def error_handler=(method_or_block)
        @error_handler = method_or_block
        FFIGeos.GEOSContext_setErrorMessageHandler_r(@ptr, @error_handler, nil)
      end

      def notice_handler(&block)
        self.notice_handler = block if block_given?
        @notice_handler
      end

      def error_handler(&block)
        self.error_handler = block if block_given?
        @error_handler
      end

      def reset_notice_handler
        self.notice_handler = method(:default_notice_handler)
      end

      def reset_error_handler
        self.error_handler = method(:default_error_handler)
      end

    # Deprecated initialization and teardown...
    else
      def initialize
        @ptr = FFI::AutoPointer.new(
          FFIGeos.initGEOS_r(
            @notice_handler = method(:default_notice_handler),
            @error_handler = method(:default_error_handler)
          ),
          self.class.method(:release)
        )
      end

      def self.release(ptr)
        FFIGeos.finishGEOS_r(ptr)
      end

      attr_reader :notice_handler

      attr_reader :error_handler
    end

    private

      def default_notice_handler(*args)
        # no-op
      end

      def default_error_handler(*args)
        raise Geos::GEOSException, sprintf(args[0], *args[1])
      end
  end

  class << self
    def version
      @version ||= FFIGeos.GEOSversion.strip
    end

    def jts_port
      @jts_port ||= FFIGeos.GEOSjtsport
    end

    def current_handle
      Thread.current[:ffi_geos_handle] ||= Geos::Handle.new
    end

    def current_handle_pointer
      current_handle.ptr
    end

    def srid_copy_policy
      Thread.current[:ffi_geos_srid_copy_policy] ||= srid_copy_policy_default
    end

    # Sets the SRID copying behaviour. This value can be one of the values
    # found in Geos::Constants::SRID_COPY_POLICIES and are local to the
    # current thread. A special value of +:default+ can also be used, which
    # will use a global default that can be set with srid_copy_policy_default=.
    # Setting this value will cause all future threads to use this global
    # default rather than the true default value which is set to +:zero+ for
    # the sake of backwards compatibility with
    #
    # The available values for +policy+ are:
    #
    # * +:default+ - use the value set with srid_copy_policy_default=,
    #   which itself is +:zero+.
    # * +:zero+ - set all SRIDs to 0. The only exception to this is when
    #   cloning a Geometry, in which the SRID is always copied as per the
    #   previous behaviour.
    # * +:lenient+ - when copying SRIDs, use the SRID of the object that the
    #   operation is being performed on, even if operation involves multiple
    #   Geometry objects that may have different SRIDs.
    # * +:strict+ - when copying SRIDs, raise a Geos::MixedSRIDsError exception
    #   if an operation is performed on mixed SRIDs. This setting
    def srid_copy_policy=(policy)
      if policy == :default
        Thread.current[:ffi_geos_srid_copy_policy] = srid_copy_policy_default
      elsif Geos::Constants::SRID_COPY_POLICIES.include?(policy)
        Thread.current[:ffi_geos_srid_copy_policy] = policy
      else
        raise ArgumentError, "Invalid SRID policy #{policy} (must be one of #{Geos::Constants::SRID_COPY_POLICIES})"
      end
    end

    def srid_copy_policy_default
      @srid_copy_policy_default ||= :zero
    end

    def srid_copy_policy_default=(policy)
      if policy == :default
        @srid_copy_policy_default = :zero
      elsif Geos::Constants::SRID_COPY_POLICIES.include?(policy)
        @srid_copy_policy_default = policy
      else
        raise ArgumentError, "Invalid SRID policy #{policy} (must be one of #{Geos::Constants::SRID_COPY_POLICIES})"
      end
    end

    %w{
      create_point
      create_line_string
      create_linear_ring
      create_polygon
      create_multi_point
      create_multi_line_string
      create_multi_polygon
      create_geometry_collection
      create_collection

      create_empty_point
      create_empty_line_string
      create_empty_polygon
      create_empty_multi_point
      create_empty_multi_line_string
      create_empty_multi_polygon
      create_empty_geometry_collection
      create_empty_collection
      create_empty_linear_ring
    }.each do |m|
      class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
        def #{m}(*args)
          Geos::Utils.#{m}(*args)
        end
      RUBY
    end
  end

  # For backwards compatibility with older native GEOS bindings.
  module GeomTypes
    GEOS_POINT = Geos::GeometryTypes[:point]
    GEOS_LINESTRING = Geos::GeometryTypes[:line_string]
    GEOS_LINEARRING = Geos::GeometryTypes[:linear_ring]
    GEOS_POLYGON = Geos::GeometryTypes[:polygon]
    GEOS_MULTIPOINT = Geos::GeometryTypes[:multi_point]
    GEOS_MULTILINESTRING = Geos::GeometryTypes[:multi_line_string]
    GEOS_MULTIPOLYGON = Geos::GeometryTypes[:multi_polygon]
    GEOS_GEOMETRYCOLLECTION = Geos::GeometryTypes[:geometry_collection]
  end

  module VersionConstants
    GEOS_JTS_PORT = Geos.jts_port
    GEOS_VERSION,
      GEOS_VERSION_MAJOR, GEOS_VERSION_MINOR, GEOS_VERSION_PATCH, GEOS_VERSION_PRERELEASE,
      GEOS_CAPI_VERSION,
      GEOS_CAPI_VERSION_MAJOR, GEOS_CAPI_VERSION_MINOR, GEOS_CAPI_VERSION_PATCH,
      GEOS_SVN_REVISION =
      if (versions = Geos.version.scan(/^
        ((\d+)\.(\d+)\.(\d+)((?:dev|rc|beta|alpha)\d*)?)
        -CAPI-
        ((\d+)\.(\d+)\.(\d+))
        (?:\s+r?(\h+))?
      $/x)).empty?
        ['0.0.0', 0, 0, 0, nil, '0.0.0', 0, 0, 0]
      else
        versions = versions[0]
        [
          versions[0],
          versions[1].to_i,
          versions[2].to_i,
          versions[3].to_i,
          versions[4],
          versions[5],
          versions[6].to_i,
          versions[7].to_i,
          versions[8].to_i,
          versions[9]&.to_i
        ]
      end
    GEOS_CAPI_FIRST_INTERFACE = GEOS_CAPI_VERSION_MAJOR.to_i
    GEOS_CAPI_LAST_INTERFACE = GEOS_CAPI_VERSION_MAJOR.to_i + GEOS_CAPI_VERSION_MINOR.to_i

    GEOS_NICE_VERSION = [GEOS_VERSION_MAJOR, GEOS_VERSION_MINOR, GEOS_VERSION_PATCH].collect { |version|
      version.to_s.rjust(2, '0')
    }.join
  end

  module Constants
    BUFFER_PARAM_DEFAULTS = {
      quad_segs: 8,
      endcap: :round,
      join: :round,
      mitre_limit: 5.0
    }.freeze

    SRID_COPY_POLICIES = [
      :zero,
      :lenient,
      :strict
    ].freeze
  end

  class Error < ::RuntimeError
  end

  class GEOSException < Error
  end

  class IndexBoundsError < Error
    def initialize(*)
      super('Index out of bounds')
    end
  end

  class MixedSRIDsError < Error
    def initialize(srid_a, srid_b)
      super("Operation on mixed SRIDs (#{srid_a} vs. #{srid_b})")
    end
  end

  class ParseError < Error
  end

  class InvalidGeometryError < Error
  end

  include GeomTypes
  include VersionConstants
end
