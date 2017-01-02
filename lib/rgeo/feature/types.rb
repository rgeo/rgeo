# -----------------------------------------------------------------------------
#
# Feature type management and casting
#
# -----------------------------------------------------------------------------

module RGeo
  module Feature
    # All geometry implementations MUST include this submodule.
    # This serves as a marker that may be used to test an object for
    # feature-ness.

    module Instance
    end

    # This module provides the API for geometry type objects. Technically
    # these objects are modules (such as ::RGeo::Feature::Point), but as
    # objects they respond to the methods documented here.
    #
    # For example, you may determine whether a feature object is a
    # point by calling:
    #
    #   ::RGeo::Feature::Point.check_type(object)
    #
    # A corresponding === operator is provided so you can use the type
    # modules in a case-when clause:
    #
    #   case object
    #   when ::RGeo::Feature::Point
    #     # do stuff here...
    #
    # However, a feature object may not actually include the point module
    # itself; hence, the following will *not* work:
    #
    #   object.is_a?(::RGeo::Feature::Point)  # DON'T DO THIS-- DOES NOT WORK
    #
    # You may obtain the type of a feature object by calling its
    # geometry_type method. You may then use the methods in this module to
    # interrogate that type.
    #
    #   # supppose object is a Point
    #   type = object.geometry_type  # ::RGeo::Feature::Point
    #   type.type_name               # "Point"
    #   type.supertype               # ::RGeo::Feature::Geometry
    #
    # You may also use the presence of this module to determine whether
    # a particular object is a feature type:
    #
    #   ::RGeo::Feature::Type === object.geometry_type  # true

    module Type
      # Deprecated alias for RGeo::Feature::Instance
      Instance = Feature::Instance

      # Returns true if the given object is this type or a subtype
      # thereof, or if it is a feature object whose geometry_type is
      # this type or a subtype thereof.
      #
      # Note that feature objects need not actually include this module.
      # Therefore, the is_a? method will generally not work.

      def check_type(rhs_)
        rhs_ = rhs_.geometry_type if rhs_.is_a?(Feature::Instance)
        rhs_.is_a?(Type) && (rhs_ == self || rhs_.include?(self))
      end
      alias_method :===, :check_type

      # Returns true if this type is the same type or a subtype of the
      # given type.

      def subtype_of?(type_)
        self == type_ || self.include?(type_)
      end

      # Returns the supertype of this type. The supertype of Geometry
      # is nil.

      def supertype
        @supertype
      end

      # Iterates over the known immediate subtypes of this type.

      def each_immediate_subtype(&block_)
        @subtypes.each(&block_) if defined?(@subtypes) && @subtypes
      end

      # Returns the OpenGIS type name of this type. For example:
      #
      #   ::RGeo::Feature::Point.type_name  # "Point"

      def type_name
        name.sub("RGeo::Feature::", "")
      end
      alias_method :to_s, :type_name

      def _add_subtype(type_) # :nodoc:
        (@subtypes ||= []) << type_
      end

      def self.extended(type_) # :nodoc:
        supertype_ = type_.included_modules.find { |m_| m_.is_a?(self) }
        type_.instance_variable_set(:@supertype, supertype_)
        supertype_._add_subtype(type_) if supertype_
      end
    end

    class << self
      # Cast the given object according to the given parameters, if
      # possible, and return the resulting object. If the requested cast
      # is not possible, nil is returned.
      #
      # Parameters may be provided as a hash, or as separate arguments.
      # Hash keys are as follows:
      #
      # [<tt>:factory</tt>]
      #   Set the factory to the given factory. If this argument is not
      #   given, the original object's factory is kept.
      # [<tt>:type</tt>]
      #   Cast to the given type, which must be a module in the
      #   RGeo::Feature namespace. If this argument is not given, the
      #   result keeps the same type as the original.
      # [<tt>:project</tt>]
      #   If this is set to true, and both the original and new factories
      #   support proj4 projections, then the cast will also cause the
      #   coordinates to be transformed between those two projections.
      #   If set to false, the coordinates are not modified. Default is
      #   false.
      # [<tt>:keep_subtype</tt>]
      #   Value must be a boolean indicating whether to keep the subtype
      #   of the original. If set to false, casting to a particular type
      #   always casts strictly to that type, even if the old type is a
      #   subtype of the new type. If set to true, the cast retains the
      #   subtype in that case. For example, casting a LinearRing to a
      #   LineString will normally yield a LineString, even though
      #   LinearRing is already a more specific subtype. If you set this
      #   value to true, the casted object will remain a LinearRing.
      #   Default is false.
      # [<tt>:force_new</tt>]
      #   Always return a newly-created object, even if neither the type
      #   nor factory is modified. Normally, if this is set to false, and
      #   a cast is not set to modify either the factory or type, the
      #   original object itself is returned. Setting this flag to true
      #   causes cast to return a clone in that case. Default is false.
      #
      # You may also pass the new factory, the new type, and the flags
      # as separate arguments. In this case, the flag names must be
      # passed as symbols, and their effect is the same as setting their
      # values to true. You can even combine separate arguments and hash
      # arguments. For example, the following three calls are equivalent:
      #
      #  RGeo::Feature.cast(geom, :type => RGeo::Feature::Point, :project => true)
      #  RGeo::Feature.cast(geom, RGeo::Feature::Point, :project => true)
      #  RGeo::Feature.cast(geom, RGeo::Feature::Point, :project)
      #
      # RGeo provides a default casting algorithm. Individual feature
      # implementation factories may override this and customize the
      # casting behavior by defining the override_cast method. See
      # ::RGeo::Feature::Factory#override_cast for more details.

      def cast(obj_, *params_)
        # Interpret params
        factory_ = obj_.factory
        type_ = obj_.geometry_type
        opts_ = {}
        params_.each do |param_|
          case param_
          when Factory::Instance
            opts_[:factory] = param_
          when Type
            opts_[:type] = param_
          when ::Symbol
            opts_[param_] = true
          when ::Hash
            opts_.merge!(param_)
          end
        end
        force_new_ = opts_[:force_new]
        keep_subtype_ = opts_[:keep_subtype]
        project_ = opts_[:project]
        nfactory_ = opts_.delete(:factory) || factory_
        ntype_ = opts_.delete(:type) || type_

        # Let the factory override
        if nfactory_.respond_to?(:override_cast)
          override_ = nfactory_.override_cast(obj_, ntype_, opts_)
          return override_ unless override_ == false
        end

        # Default algorithm
        ntype_ = type_ if keep_subtype_ && type_.include?(ntype_)
        if ntype_ == type_
          # Types are the same
          if nfactory_ == factory_
            force_new_ ? obj_.dup : obj_
          else
            if type_ == Point
              proj_ = nproj_ = nil
              if project_
                proj_ = factory_.proj4
                nproj_ = nfactory_.proj4
              end
              hasz_ = factory_.property(:has_z_coordinate)
              nhasz_ = nfactory_.property(:has_z_coordinate)
              if proj_ && nproj_
                coords_ = CoordSys::Proj4.transform_coords(proj_, nproj_, obj_.x, obj_.y, hasz_ ? obj_.z : nil)
                coords_ << (hasz_ ? obj_.z : 0.0) if nhasz_ && coords_.size < 3
              else
                coords_ = [obj_.x, obj_.y]
                coords_ << (hasz_ ? obj_.z : 0.0) if nhasz_
              end
              coords_ << (factory_.property(:has_m_coordinate) ? obj_.m : 0.0) if nfactory_.property(:has_m_coordinate)
              nfactory_.point(*coords_)
            elsif type_ == Line
              nfactory_.line(cast(obj_.start_point, nfactory_, opts_), cast(obj_.end_point, nfactory_, opts_))
            elsif type_ == LinearRing
              nfactory_.linear_ring(obj_.points.map { |p_| cast(p_, nfactory_, opts_) })
            elsif type_ == LineString
              nfactory_.line_string(obj_.points.map { |p_| cast(p_, nfactory_, opts_) })
            elsif type_ == Polygon
              nfactory_.polygon(cast(obj_.exterior_ring, nfactory_, opts_),
                                obj_.interior_rings.map { |r_| cast(r_, nfactory_, opts_) })
            elsif type_ == MultiPoint
              nfactory_.multi_point(obj_.map { |g_| cast(g_, nfactory_, opts_) })
            elsif type_ == MultiLineString
              nfactory_.multi_line_string(obj_.map { |g_| cast(g_, nfactory_, opts_) })
            elsif type_ == MultiPolygon
              nfactory_.multi_polygon(obj_.map { |g_| cast(g_, nfactory_, opts_) })
            elsif type_ == GeometryCollection
              nfactory_.collection(obj_.map { |g_| cast(g_, nfactory_, opts_) })
            end
          end
        else
          # Types are different
          if ntype_ == Point && (type_ == MultiPoint || type_ == GeometryCollection) ||
              (ntype_ == Line || ntype_ == LineString || ntype_ == LinearRing) && (type_ == MultiLineString || type_ == GeometryCollection) ||
              ntype_ == Polygon && (type_ == MultiPolygon || type_ == GeometryCollection)
            if obj_.num_geometries == 1
              cast(obj_.geometry_n(0), nfactory_, ntype_, opts_)
            end
          elsif ntype_ == Point
            nil
          elsif ntype_ == Line
            if type_ == LineString && obj_.num_points == 2
              nfactory_.line(cast(obj_.point_n(0), nfactory_, opts_), cast(obj_.point_n(1), nfactory_, opts_))
            end
          elsif ntype_ == LinearRing
            if type_ == LineString
              nfactory_.linear_ring(obj_.points.map { |p_| cast(p_, nfactory_, opts_) })
            end
          elsif ntype_ == LineString
            if type_ == Line || type_ == LinearRing
              nfactory_.line_string(obj_.points.map { |p_| cast(p_, nfactory_, opts_) })
            end
          elsif ntype_ == MultiPoint
            if type_ == Point
              nfactory_.multi_point([cast(obj_, nfactory_, opts_)])
            elsif type_ == GeometryCollection
              nfactory_.multi_point(obj_.map { |p_| cast(p_, nfactory_, opts_) })
            end
          elsif ntype_ == MultiLineString
            if type_ == Line || type_ == LinearRing || type_ == LineString
              nfactory_.multi_line_string([cast(obj_, nfactory_, opts_)])
            elsif type_ == GeometryCollection
              nfactory_.multi_line_string(obj_.map { |p_| cast(p_, nfactory_, opts_) })
            end
          elsif ntype_ == MultiPolygon
            if type_ == Polygon
              nfactory_.multi_polygon([cast(obj_, nfactory_, opts_)])
            elsif type_ == GeometryCollection
              nfactory_.multi_polygon(obj_.map { |p_| cast(p_, nfactory_, opts_) })
            end
          elsif ntype_ == GeometryCollection
            if type_ == MultiPoint || type_ == MultiLineString || type_ == MultiPolygon
              nfactory_.collection(obj_.map { |p_| cast(p_, nfactory_, opts_) })
            else
              nfactory_.collection([cast(obj_, nfactory_, opts_)])
            end
          end
        end
      end
    end
  end
end
