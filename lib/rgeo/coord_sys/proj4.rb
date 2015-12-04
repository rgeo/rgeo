# -----------------------------------------------------------------------------
#
# Proj4 wrapper for RGeo
#
# -----------------------------------------------------------------------------

module RGeo
  module CoordSys
    # This is a Ruby wrapper around a Proj4 coordinate system.
    # It represents a single geographic coordinate system, which may be
    # a flat projection, a geocentric (3-dimensional) coordinate system,
    # or a geographic (latitude-longitude) coordinate system.
    #
    # Generally, these are used to define the projection for a
    # Feature::Factory. You can then convert between coordinate systems
    # by casting geometries between such factories using the :project
    # option. You may also use this object directly to perform low-level
    # coordinate transformations.

    class Proj4
      def inspect # :nodoc:
        "#<#{self.class}:0x#{object_id.to_s(16)} #{canonical_str.inspect}>"
      end

      def to_s  # :nodoc:
        canonical_str
      end

      def hash  # :nodoc:
        @hash ||= canonical_hash.hash
      end

      # Returns true if this Proj4 is equivalent to the given Proj4.
      #
      # Note: this tests for equivalence by comparing only the hash
      # definitions of the Proj4 objects, and returning true if those
      # definitions are equivalent. In some cases, this may still return
      # false even if the actual coordinate systems are identical, since
      # there are sometimes multiple ways to express a given coordinate
      # system.

      def eql?(rhs_)
        rhs_.class == self.class && rhs_.canonical_hash == canonical_hash && rhs_._radians? == _radians?
      end
      alias_method :==, :eql?

      # Marshal support

      def marshal_dump # :nodoc:
        { "rad" => radians?, "str" => original_str || canonical_str }
      end

      def marshal_load(data_) # :nodoc:
        _set_value(data_["str"], data_["rad"])
      end

      # Psych support

      def encode_with(coder_) # :nodoc:
        coder_["proj4"] = original_str || canonical_str
        coder_["radians"] = radians?
      end

      def init_with(coder_) # :nodoc:
        if coder_.type == :scalar
          _set_value(coder_.scalar, false)
        else
          _set_value(coder_["proj4"], coder_["radians"])
        end
      end

      # Returns the "canonical" string definition for this coordinate
      # system, as reported by Proj4. This may be slightly different
      # from the definition used to construct this object.

      def canonical_str
        unless defined?(@canonical_str)
          @canonical_str = _canonical_str
          if @canonical_str.respond_to?(:force_encoding)
            @canonical_str.force_encoding("US-ASCII")
          end
        end
        @canonical_str
      end

      # Returns the "canonical" hash definition for this coordinate
      # system, as reported by Proj4. This may be slightly different
      # from the definition used to construct this object.

      def canonical_hash
        unless defined?(@canonical_hash)
          @canonical_hash = {}
          canonical_str.strip.split(/\s+/).each do |elem_|
            @canonical_hash[Regexp.last_match(1)] = Regexp.last_match(3) if elem_ =~ /^\+(\w+)(=(\S+))?$/
          end
        end
        @canonical_hash
      end

      # Returns the string definition originally used to construct this
      # object. Returns nil if this object wasn't created by a string
      # definition; i.e. if it was created using get_geographic.

      def original_str
        _original_str
      end

      # Returns true if this Proj4 object is a geographic (lat-long)
      # coordinate system.

      def geographic?
        _geographic?
      end

      # Returns true if this Proj4 object is a geocentric (3dz)
      # coordinate system.

      def geocentric?
        _geocentric?
      end

      # Returns true if this Proj4 object uses radians rather than degrees
      # if it is a geographic coordinate system.

      def radians?
        _radians?
      end

      # Get the geographic (unprojected lat-long) coordinate system
      # corresponding to this coordinate system; i.e. the one that uses
      # the same ellipsoid and datum.

      def get_geographic
        _get_geographic
      end

      class << self
        # Returns true if Proj4 is supported in this installation.
        # If this returns false, the other methods such as create
        # will not work.

        def supported?
          respond_to?(:_create)
        end

        # Returns the Proj library version as a string of the format "x.y.z".

        def version
          ::RGeo::VERSION
        end

        # Create a new Proj4 object, given a definition, which may be
        # either a string or a hash. Returns nil if the given definition
        # is invalid or Proj4 is not supported.
        #
        # Recognized options include:
        #
        # [<tt>:radians</tt>]
        #   If set to true, then this proj4 will represent geographic
        #   (latitude/longitude) coordinates in radians rather than
        #   degrees. If this is a geographic coordinate system, then its
        #   units will be in radians. If this is a projected coordinate
        #   system, then its units will be unchanged, but any geographic
        #   coordinate system obtained using get_geographic will use
        #   radians as its units. If this is a geocentric or other type of
        #   coordinate system, this has no effect. Default is false.
        #   (That is all coordinates are in degrees by default.)

        def create(defn_, opts_ = {})
          result_ = nil
          if supported?
            if defn_.is_a?(::Hash)
              defn_ = defn_.map { |k_, v_| v_ ? "+#{k_}=#{v_}" : "+#{k_}" }.join(" ")
            end
            unless defn_ =~ /^\s*\+/
              defn_ = defn_.sub(/^(\s*)/, '\1+').gsub(/(\s+)([^+\s])/, '\1+\2')
            end
            result_ = _create(defn_, opts_[:radians])
            result_ = nil unless result_._valid?
          end
          result_
        end

        # Create a new Proj4 object, given a definition, which may be
        # either a string or a hash. Raises Error::UnsupportedOperation
        # if the given definition is invalid or Proj4 is not supported.
        #
        # Recognized options include:
        #
        # [<tt>:radians</tt>]
        #   If set to true, then this proj4 will represent geographic
        #   (latitude/longitude) coordinates in radians rather than
        #   degrees. If this is a geographic coordinate system, then its
        #   units will be in radians. If this is a projected coordinate
        #   system, then its units will be unchanged, but any geographic
        #   coordinate system obtained using get_geographic will use
        #   radians as its units. If this is a geocentric or other type of
        #   coordinate system, this has no effect. Default is false.
        #   (That is all coordinates are in degrees by default.)

        def new(defn_, opts_ = {})
          result_ = create(defn_, opts_)
          unless result_
            raise Error::UnsupportedOperation, "Proj4 not supported in this installation"
          end
          result_
        end

        # Low-level coordinate transform method.
        # Transforms the given coordinate (x, y, [z]) from one proj4
        # coordinate system to another. Returns an array with either two
        # or three elements.

        def transform_coords(from_proj_, to_proj_, x_, y_, z_ = nil)
          if !from_proj_._radians? && from_proj_._geographic?
            x_ *= ImplHelper::Math::RADIANS_PER_DEGREE
            y_ *= ImplHelper::Math::RADIANS_PER_DEGREE
          end
          result_ = _transform_coords(from_proj_, to_proj_, x_, y_, z_)
          if result_ && !to_proj_._radians? && to_proj_._geographic?
            result_[0] *= ImplHelper::Math::DEGREES_PER_RADIAN
            result_[1] *= ImplHelper::Math::DEGREES_PER_RADIAN
          end
          result_
        end

        # Low-level geometry transform method.
        # Transforms the given geometry between the given two projections.
        # The resulting geometry is constructed using the to_factory.
        # Any projections associated with the factories themselves are
        # ignored.

        def transform(from_proj_, from_geometry_, to_proj_, to_factory_)
          case from_geometry_
          when Feature::Point
            _transform_point(from_proj_, from_geometry_, to_proj_, to_factory_)
          when Feature::Line
            to_factory_.line(from_geometry_.points.map { |p_| _transform_point(from_proj_, p_, to_proj_, to_factory_) })
          when Feature::LinearRing
            _transform_linear_ring(from_proj_, from_geometry_, to_proj_, to_factory_)
          when Feature::LineString
            to_factory_.line_string(from_geometry_.points.map { |p_| _transform_point(from_proj_, p_, to_proj_, to_factory_) })
          when Feature::Polygon
            _transform_polygon(from_proj_, from_geometry_, to_proj_, to_factory_)
          when Feature::MultiPoint
            to_factory_.multi_point(from_geometry_.map { |p_| _transform_point(from_proj_, p_, to_proj_, to_factory_) })
          when Feature::MultiLineString
            to_factory_.multi_line_string(from_geometry_.map { |g_| transform(from_proj_, g_, to_proj_, to_factory_) })
          when Feature::MultiPolygon
            to_factory_.multi_polygon(from_geometry_.map { |p_| _transform_polygon(from_proj_, p_, to_proj_, to_factory_) })
          when Feature::GeometryCollection
            to_factory_.collection(from_geometry_.map { |g_| transform(from_proj_, g_, to_proj_, to_factory_) })
          end
        end

        def _transform_point(from_proj_, from_point_, to_proj_, to_factory_) # :nodoc:
          from_factory_ = from_point_.factory
          from_has_z_ = from_factory_.property(:has_z_coordinate)
          from_has_m_ = from_factory_.property(:has_m_coordinate)
          to_has_z_ = to_factory_.property(:has_z_coordinate)
          to_has_m_ = to_factory_.property(:has_m_coordinate)
          x_ = from_point_.x
          y_ = from_point_.y
          if !from_proj_._radians? && from_proj_._geographic?
            x_ *= ImplHelper::Math::RADIANS_PER_DEGREE
            y_ *= ImplHelper::Math::RADIANS_PER_DEGREE
          end
          coords_ = _transform_coords(from_proj_, to_proj_, x_, y_, from_has_z_ ? from_point_.z : nil)
          if coords_
            if !to_proj_._radians? && to_proj_._geographic?
              coords_[0] *= ImplHelper::Math::DEGREES_PER_RADIAN
              coords_[1] *= ImplHelper::Math::DEGREES_PER_RADIAN
            end
            extras_ = []
            extras_ << coords_[2].to_f if to_has_z_
            extras_ << from_has_m_ ? from_point_.m : 0.0 if to_has_m_
            to_factory_.point(coords_[0], coords_[1], *extras_)
          end
        end

        def _transform_linear_ring(from_proj_, from_ring_, to_proj_, to_factory_) # :nodoc:
          to_factory_.linear_ring(from_ring_.points[0..-2].map { |p_| _transform_point(from_proj_, p_, to_proj_, to_factory_) })
        end

        def _transform_polygon(from_proj_, from_polygon_, to_proj_, to_factory_) # :nodoc:
          ext_ = _transform_linear_ring(from_proj_, from_polygon_.exterior_ring, to_proj_, to_factory_)
          int_ = from_polygon_.interior_rings.map { |r_| _transform_linear_ring(from_proj_, r_, to_proj_, to_factory_) }
          to_factory_.polygon(ext_, int_)
        end
      end
    end
  end
end
