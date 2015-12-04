# -----------------------------------------------------------------------------
#
# FFI-GEOS factory implementation
#
# -----------------------------------------------------------------------------

module RGeo
  module Geos
    # This the FFI-GEOS implementation of ::RGeo::Feature::Factory.

    class FFIFactory
      include Feature::Factory::Instance

      # Create a new factory. Returns nil if the FFI-GEOS implementation
      # is not supported.
      #
      # See ::RGeo::Geos.factory for a list of supported options.

      def initialize(opts_ = {})
        # Main flags
        @uses_lenient_multi_polygon_assertions = opts_[:uses_lenient_assertions] ||
          opts_[:lenient_multi_polygon_assertions] || opts_[:uses_lenient_multi_polygon_assertions]
        @has_z = opts_[:has_z_coordinate] ? true : false
        @has_m = opts_[:has_m_coordinate] ? true : false
        if @has_z && @has_m
          raise Error::UnsupportedOperation, "GEOS cannot support both Z and M coordinates at the same time."
        end
        @_has_3d = @has_z || @has_m
        @buffer_resolution = opts_[:buffer_resolution].to_i
        @buffer_resolution = 1 if @buffer_resolution < 1
        @_auto_prepare = opts_[:auto_prepare] == :disabled ? false : true

        # Interpret the generator options
        wkt_generator_ = opts_[:wkt_generator]
        case wkt_generator_
        when :geos
          @wkt_writer = ::Geos::WktWriter.new
          @wkt_generator = nil
        when ::Hash
          @wkt_generator = WKRep::WKTGenerator.new(wkt_generator_)
          @wkt_writer = nil
        else
          @wkt_generator = WKRep::WKTGenerator.new(convert_case: :upper)
          @wkt_writer = nil
        end
        wkb_generator_ = opts_[:wkb_generator]
        case wkb_generator_
        when :geos
          @wkb_writer = ::Geos::WkbWriter.new
          @wkb_generator = nil
        when ::Hash
          @wkb_generator = WKRep::WKBGenerator.new(wkb_generator_)
          @wkb_writer = nil
        else
          @wkb_generator = WKRep::WKBGenerator.new
          @wkb_writer = nil
        end

        # Coordinate system (srid, proj4, and coord_sys)
        @srid = opts_[:srid]
        @proj4 = opts_[:proj4]
        if CoordSys::Proj4.supported?
          if @proj4.is_a?(::String) || @proj4.is_a?(::Hash)
            @proj4 = CoordSys::Proj4.create(@proj4)
          end
        else
          @proj4 = nil
        end
        @coord_sys = opts_[:coord_sys]
        if @coord_sys.is_a?(::String)
          @coord_sys = begin
                         CoordSys::CS.create_from_wkt(@coord_sys)
                       rescue
                         nil
                       end
        end
        if (!@proj4 || !@coord_sys) && @srid && (db_ = opts_[:srs_database])
          entry_ = db_.get(@srid.to_i)
          if entry_
            @proj4 ||= entry_.proj4
            @coord_sys ||= entry_.coord_sys
          end
        end
        @srid ||= @coord_sys.authority_code if @coord_sys
        @srid = @srid.to_i

        # Interpret parser options
        wkt_parser_ = opts_[:wkt_parser]
        case wkt_parser_
        when :geos
          @wkt_reader = ::Geos::WktReader.new
          @wkt_parser = nil
        when ::Hash
          @wkt_parser = WKRep::WKTParser.new(self, wkt_parser_)
          @wkt_reader = nil
        else
          @wkt_parser = WKRep::WKTParser.new(self)
          @wkt_reader = nil
        end
        wkb_parser_ = opts_[:wkb_parser]
        case wkb_parser_
        when :geos
          @wkb_reader = ::Geos::WkbReader.new
          @wkb_parser = nil
        when ::Hash
          @wkb_parser = WKRep::WKBParser.new(self, wkb_parser_)
          @wkb_reader = nil
        else
          @wkb_parser = WKRep::WKBParser.new(self)
          @wkb_reader = nil
        end
      end

      # Standard object inspection output

      def inspect
        "#<#{self.class}:0x#{object_id.to_s(16)} srid=#{srid}>"
      end

      # Factory equivalence test.

      def eql?(rhs_)
        rhs_.is_a?(self.class) && @srid == rhs_.srid &&
          @has_z == rhs_.property(:has_z_coordinate) &&
          @has_m == rhs_.property(:has_m_coordinate) &&
          @buffer_resolution == rhs_.property(:buffer_resolution) &&
          @proj4.eql?(rhs_.proj4)
      end
      alias_method :==, :eql?

      # Standard hash code

      def hash
        @hash ||= [@srid, @has_z, @has_m, @buffer_resolution, @proj4].hash
      end

      # Marshal support

      def marshal_dump # :nodoc:
        hash_ = {
          "hasz" => @has_z,
          "hasm" => @has_m,
          "srid" => @srid,
          "bufr" => @buffer_resolution,
          "wktg" => @wkt_generator._properties,
          "wkbg" => @wkb_generator._properties,
          "wktp" => @wkt_parser._properties,
          "wkbp" => @wkb_parser._properties,
          "lmpa" => @uses_lenient_multi_polygon_assertions,
          "apre" => @_auto_prepare
        }
        hash_["proj4"] = @proj4.marshal_dump if @proj4
        hash_["cs"] = @coord_sys.to_wkt if @coord_sys
        hash_
      end

      def marshal_load(data_) # :nodoc:
        if CoordSys::Proj4.supported? && (proj4_data_ = data_["proj4"])
          proj4_ = CoordSys::Proj4.allocate
          proj4_.marshal_load(proj4_data_)
        else
          proj4_ = nil
        end
        if (coord_sys_data_ = data_["cs"])
          coord_sys_ = CoordSys::CS.create_from_wkt(coord_sys_data_)
        else
          coord_sys_ = nil
        end
        initialize(
          has_z_coordinate: data_["hasz"],
          has_m_coordinate: data_["hasm"],
          srid: data_["srid"],
          buffer_resolution: data_["bufr"],
          wkt_generator: ImplHelper::Utils.symbolize_hash(data_["wktg"]),
          wkb_generator: ImplHelper::Utils.symbolize_hash(data_["wkbg"]),
          wkt_parser: ImplHelper::Utils.symbolize_hash(data_["wktp"]),
          wkb_parser: ImplHelper::Utils.symbolize_hash(data_["wkbp"]),
          uses_lenient_multi_polygon_assertions: data_["lmpa"],
          auto_prepare: (data_["apre"] ? :simple : :disabled),
          proj4: proj4_,
          coord_sys: coord_sys_
        )
      end

      # Psych support

      def encode_with(coder_) # :nodoc:
        coder_["has_z_coordinate"] = @has_z
        coder_["has_m_coordinate"] = @has_m
        coder_["srid"] = @srid
        coder_["buffer_resolution"] = @buffer_resolution
        coder_["lenient_multi_polygon_assertions"] = @uses_lenient_multi_polygon_assertions
        coder_["wkt_generator"] = @wkt_generator._properties
        coder_["wkb_generator"] = @wkb_generator._properties
        coder_["wkt_parser"] = @wkt_parser._properties
        coder_["wkb_parser"] = @wkb_parser._properties
        coder_["auto_prepare"] = @_auto_prepare ? "simple" : "disabled"
        if @proj4
          str_ = @proj4.original_str || @proj4.canonical_str
          coder_["proj4"] = @proj4.radians? ? { "proj4" => str_, "radians" => true } : str_
        end
        coder_["coord_sys"] = @coord_sys.to_wkt if @coord_sys
      end

      def init_with(coder_) # :nodoc:
        if (proj4_data_ = coder_["proj4"])
          if proj4_data_.is_a?(::Hash)
            proj4_ = CoordSys::Proj4.create(proj4_data_["proj4"], radians: proj4_data_["radians"])
          else
            proj4_ = CoordSys::Proj4.create(proj4_data_.to_s)
          end
        else
          proj4_ = nil
        end
        if (coord_sys_data_ = coder_["cs"])
          coord_sys_ = CoordSys::CS.create_from_wkt(coord_sys_data_.to_s)
        else
          coord_sys_ = nil
        end
        initialize(
          has_z_coordinate: coder_["has_z_coordinate"],
          has_m_coordinate: coder_["has_m_coordinate"],
          srid: coder_["srid"],
          buffer_resolution: coder_["buffer_resolution"],
          wkt_generator: ImplHelper::Utils.symbolize_hash(coder_["wkt_generator"]),
          wkb_generator: ImplHelper::Utils.symbolize_hash(coder_["wkb_generator"]),
          wkt_parser: ImplHelper::Utils.symbolize_hash(coder_["wkt_parser"]),
          wkb_parser: ImplHelper::Utils.symbolize_hash(coder_["wkb_parser"]),
          auto_prepare: coder_["auto_prepare"] == "disabled" ? :disabled : :simple,
          uses_lenient_multi_polygon_assertions: coder_["lenient_multi_polygon_assertions"],
          proj4: proj4_,
          coord_sys: coord_sys_
        )
      end

      # Returns the SRID of geometries created by this factory.

      attr_reader :srid

      # Returns the resolution used by buffer calculations on geometries
      # created by this factory

      attr_reader :buffer_resolution

      # Returns true if this factory is lenient with MultiPolygon assertions

      def lenient_multi_polygon_assertions?
        @uses_lenient_multi_polygon_assertions
      end

      # See ::RGeo::Feature::Factory#property

      def property(name_)
        case name_
        when :has_z_coordinate
          @has_z
        when :has_m_coordinate
          @has_m
        when :is_cartesian
          true
        when :buffer_resolution
          @buffer_resolution
        when :uses_lenient_multi_polygon_assertions
          @uses_lenient_multi_polygon_assertions
        when :auto_prepare
          @_auto_prepare ? :simple : :disabled
        end
      end

      # Create a feature that wraps the given ffi-geos geometry object

      def wrap_fg_geom(fg_geom_)
        _wrap_fg_geom(fg_geom_, nil)
      end

      # See ::RGeo::Feature::Factory#parse_wkt

      def parse_wkt(str_)
        if @wkt_reader
          _wrap_fg_geom(@wkt_reader.read(str_), nil)
        else
          @wkt_parser.parse(str_)
        end
      end

      # See ::RGeo::Feature::Factory#parse_wkb

      def parse_wkb(str_)
        if @wkb_reader
          _wrap_fg_geom(@wkb_reader.read(str_), nil)
        else
          @wkb_parser.parse(str_)
        end
      end

      # See ::RGeo::Feature::Factory#point

      def point(x_, y_, z_ = 0)
        cs_ = ::Geos::CoordinateSequence.new(1, 3)
        cs_.set_x(0, x_)
        cs_.set_y(0, y_)
        cs_.set_z(0, z_)
        FFIPointImpl.new(self, ::Geos::Utils.create_point(cs_), nil)
      end

      # See ::RGeo::Feature::Factory#line_string

      def line_string(points_)
        points_ = points_.to_a unless points_.is_a?(::Array)
        size_ = points_.size
        return nil if size_ == 1
        cs_ = ::Geos::CoordinateSequence.new(size_, 3)
        points_.each_with_index do |p_, i_|
          return nil unless ::RGeo::Feature::Point.check_type(p_)
          cs_.set_x(i_, p_.x)
          cs_.set_y(i_, p_.y)
          if @has_z
            cs_.set_z(i_, p_.z)
          elsif @has_m
            cs_.set_z(i_, p_.m)
          end
        end
        FFILineStringImpl.new(self, ::Geos::Utils.create_line_string(cs_), nil)
      end

      # See ::RGeo::Feature::Factory#line

      def line(start_, end_)
        return nil unless ::RGeo::Feature::Point.check_type(start_) &&
          ::RGeo::Feature::Point.check_type(end_)
        cs_ = ::Geos::CoordinateSequence.new(2, 3)
        cs_.set_x(0, start_.x)
        cs_.set_x(1, end_.x)
        cs_.set_y(0, start_.y)
        cs_.set_y(1, end_.y)
        if @has_z
          cs_.set_z(0, start_.z)
          cs_.set_z(1, end_.z)
        elsif @has_m
          cs_.set_z(0, start_.m)
          cs_.set_z(1, end_.m)
        end
        FFILineImpl.new(self, ::Geos::Utils.create_line_string(cs_), nil)
      end

      # See ::RGeo::Feature::Factory#linear_ring

      def linear_ring(points_)
        points_ = points_.to_a unless points_.is_a?(::Array)
        fg_geom_ = _create_fg_linear_ring(points_)
        fg_geom_ ? FFILinearRingImpl.new(self, fg_geom_, nil) : nil
      end

      # See ::RGeo::Feature::Factory#polygon

      def polygon(outer_ring_, inner_rings_ = nil)
        inner_rings_ = inner_rings_.to_a unless inner_rings_.is_a?(::Array)
        return nil unless ::RGeo::Feature::LineString.check_type(outer_ring_)
        outer_ring_ = _create_fg_linear_ring(outer_ring_.points)
        inner_rings_ = inner_rings_.map do |r_|
          return nil unless ::RGeo::Feature::LineString.check_type(r_)
          _create_fg_linear_ring(r_.points)
        end
        inner_rings_.compact!
        fg_geom_ = ::Geos::Utils.create_polygon(outer_ring_, *inner_rings_)
        fg_geom_ ? FFIPolygonImpl.new(self, fg_geom_, nil) : nil
      end

      # See ::RGeo::Feature::Factory#collection

      def collection(elems_)
        elems_ = elems_.to_a unless elems_.is_a?(::Array)
        klasses_ = []
        fg_geoms_ = []
        elems_.each do |elem_|
          k_ = elem_._klasses if elem_.factory.is_a?(FFIFactory)
          elem_ = ::RGeo::Feature.cast(elem_, self, :force_new, :keep_subtype)
          if elem_
            klasses_ << (k_ || elem_.class)
            fg_geoms_ << elem_._detach_fg_geom
          end
        end
        fg_geom_ = ::Geos::Utils.create_collection(
          ::Geos::GeomTypes::GEOS_GEOMETRYCOLLECTION, fg_geoms_)
        fg_geom_ ? FFIGeometryCollectionImpl.new(self, fg_geom_, klasses_) : nil
      end

      # See ::RGeo::Feature::Factory#multi_point

      def multi_point(elems_)
        elems_ = elems_.to_a unless elems_.is_a?(::Array)
        elems_ = elems_.map do |elem_|
          elem_ = ::RGeo::Feature.cast(elem_, self, ::RGeo::Feature::Point,
            :force_new, :keep_subtype)
          return nil unless elem_
          elem_._detach_fg_geom
        end
        klasses_ = ::Array.new(elems_.size, FFIPointImpl)
        fg_geom_ = ::Geos::Utils.create_collection(
          ::Geos::GeomTypes::GEOS_MULTIPOINT, elems_)
        fg_geom_ ? FFIMultiPointImpl.new(self, fg_geom_, klasses_) : nil
      end

      # See ::RGeo::Feature::Factory#multi_line_string

      def multi_line_string(elems_)
        elems_ = elems_.to_a unless elems_.is_a?(::Array)
        klasses_ = []
        elems_ = elems_.map do |elem_|
          elem_ = ::RGeo::Feature.cast(elem_, self, ::RGeo::Feature::LineString,
            :force_new, :keep_subtype)
          return nil unless elem_
          klasses_ << elem_.class
          elem_._detach_fg_geom
        end
        fg_geom_ = ::Geos::Utils.create_collection(
          ::Geos::GeomTypes::GEOS_MULTILINESTRING, elems_)
        fg_geom_ ? FFIMultiLineStringImpl.new(self, fg_geom_, klasses_) : nil
      end

      # See ::RGeo::Feature::Factory#multi_polygon

      def multi_polygon(elems_)
        elems_ = elems_.to_a unless elems_.is_a?(::Array)
        elems_ = elems_.map do |elem_|
          elem_ = ::RGeo::Feature.cast(elem_, self, ::RGeo::Feature::Polygon,
            :force_new, :keep_subtype)
          return nil unless elem_
          elem_._detach_fg_geom
        end
        unless @uses_lenient_multi_polygon_assertions
          (1...elems_.size).each do |i_|
            (0...i_).each do |j_|
              igeom_ = elems_[i_]
              jgeom_ = elems_[j_]
              return nil if igeom_.relate_pattern(jgeom_, "2********") ||
                igeom_.relate_pattern(jgeom_, "****1****")
            end
          end
        end
        klasses_ = ::Array.new(elems_.size, FFIPolygonImpl)
        fg_geom_ = ::Geos::Utils.create_collection(
          ::Geos::GeomTypes::GEOS_MULTIPOLYGON, elems_)
        fg_geom_ ? FFIMultiPolygonImpl.new(self, fg_geom_, klasses_) : nil
      end

      # See ::RGeo::Feature::Factory#proj4

      attr_reader :proj4

      # See ::RGeo::Feature::Factory#coord_sys

      attr_reader :coord_sys

      # See ::RGeo::Feature::Factory#override_cast

      def override_cast(_original_, _ntype_, _flags_)
        false
        # TODO
      end

      attr_reader :_has_3d # :nodoc:
      attr_reader :_auto_prepare # :nodoc:

      def _wrap_fg_geom(fg_geom_, klass_) # :nodoc:
        klasses_ = nil

        # We don't allow "empty" points, so replace such objects with
        # an empty collection.
        if fg_geom_.type_id == ::Geos::GeomTypes::GEOS_POINT && fg_geom_.empty?
          fg_geom_ = ::Geos::Utils.create_geometry_collection
          klass_ = FFIGeometryCollectionImpl
        end

        unless klass_.is_a?(::Class)
          is_collection_ = false
          case fg_geom_.type_id
          when ::Geos::GeomTypes::GEOS_POINT
            inferred_klass_ = FFIPointImpl
          when ::Geos::GeomTypes::GEOS_MULTIPOINT
            inferred_klass_ = FFIMultiPointImpl
            is_collection_ = true
          when ::Geos::GeomTypes::GEOS_LINESTRING
            inferred_klass_ = FFILineStringImpl
          when ::Geos::GeomTypes::GEOS_LINEARRING
            inferred_klass_ = FFILinearRingImpl
          when ::Geos::GeomTypes::GEOS_MULTILINESTRING
            inferred_klass_ = FFIMultiLineStringImpl
            is_collection_ = true
          when ::Geos::GeomTypes::GEOS_POLYGON
            inferred_klass_ = FFIPolygonImpl
          when ::Geos::GeomTypes::GEOS_MULTIPOLYGON
            inferred_klass_ = FFIMultiPolygonImpl
            is_collection_ = true
          when ::Geos::GeomTypes::GEOS_GEOMETRYCOLLECTION
            inferred_klass_ = FFIGeometryCollectionImpl
            is_collection_ = true
          else
            inferred_klass_ = FFIGeometryImpl
          end
          klasses_ = klass_ if is_collection_ && klass_.is_a?(::Array)
          klass_ = inferred_klass_
        end
        klass_.new(self, fg_geom_, klasses_)
      end

      def _convert_to_fg_geometry(obj_, type_ = nil) # :nodoc:
        if type_.nil? && obj_.factory == self
          obj_
        else
          obj_ = Feature.cast(obj_, self, type_)
        end
        obj_ ? obj_.fg_geom : nil
      end

      def _create_fg_linear_ring(points_) # :nodoc:
        size_ = points_.size
        return nil if size_ == 1 || size_ == 2
        if size_ > 0 && points_.first != points_.last
          points_ += [points_.first]
          size_ += 1
        end
        cs_ = ::Geos::CoordinateSequence.new(size_, 3)
        points_.each_with_index do |p_, i_|
          return nil unless ::RGeo::Feature::Point.check_type(p_)
          cs_.set_x(i_, p_.x)
          cs_.set_y(i_, p_.y)
          if @has_z
            cs_.set_z(i_, p_.z)
          elsif @has_m
            cs_.set_z(i_, p_.m)
          end
        end
        ::Geos::Utils.create_linear_ring(cs_)
      end

      def _generate_wkt(geom_)  # :nodoc:
        if @wkt_writer
          @wkt_writer.write(geom_.fg_geom)
        else
          @wkt_generator.generate(geom_)
        end
      end

      def _generate_wkb(geom_)  # :nodoc:
        if @wkb_writer
          @wkb_writer.write(geom_.fg_geom)
        else
          @wkb_generator.generate(geom_)
        end
      end

      def _write_for_marshal(geom_) # :nodoc:
        if Utils.ffi_supports_set_output_dimension || !@_has_3d
          unless defined?(@marshal_wkb_writer)
            @marshal_wkb_writer = ::Geos::WkbWriter.new
            @marshal_wkb_writer.output_dimensions = 3 if @_has_3d
          end
          @marshal_wkb_writer.write(geom_.fg_geom)
        else
          Utils.marshal_wkb_generator.generate(geom_)
        end
      end

      def _read_for_marshal(str_)  # :nodoc:
        unless defined?(@marshal_wkb_reader)
          @marshal_wkb_reader = ::Geos::WkbReader.new
        end
        @marshal_wkb_reader.read(str_)
      end

      def _write_for_psych(geom_)  # :nodoc:
        if Utils.ffi_supports_set_output_dimension || !@_has_3d
          unless defined?(@psych_wkt_writer)
            @psych_wkt_writer = ::Geos::WktWriter.new
            @psych_wkt_writer.output_dimensions = 3 if @_has_3d
          end
          @psych_wkt_writer.write(geom_.fg_geom)
        else
          Utils.psych_wkt_generator.generate(geom_)
        end
      end

      def _read_for_psych(str_) # :nodoc:
        unless defined?(@psych_wkt_reader)
          @psych_wkt_reader = ::Geos::WktReader.new
        end
        @psych_wkt_reader.read(str_)
      end
    end
  end
end
