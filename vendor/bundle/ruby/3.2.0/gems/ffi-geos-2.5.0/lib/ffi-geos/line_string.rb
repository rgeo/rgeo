# frozen_string_literal: true

module Geos
  class LineString < Geometry
    include Enumerable

    def each
      if block_given?
        num_points.times do |n|
          yield point_n(n)
        end
        self
      else
        num_points.times.collect { |n|
          point_n(n)
        }.to_enum
      end
    end

    if FFIGeos.respond_to?(:GEOSGeomGetNumPoints_r)
      def num_points
        FFIGeos.GEOSGeomGetNumPoints_r(Geos.current_handle_pointer, ptr)
      end
    else
      def num_points
        coord_seq.length
      end
    end

    def point_n(n)
      raise Geos::IndexBoundsError if n.negative? || n >= num_points

      cast_geometry_ptr(FFIGeos.GEOSGeomGetPointN_r(Geos.current_handle_pointer, ptr, n), srid_copy: srid)
    end

    def [](*args)
      if args.length == 1 && args.first.is_a?(Numeric) && args.first >= 0
        point_n(args.first)
      else
        to_a[*args]
      end
    end
    alias slice []

    def offset_curve(width, **options)
      options = Constants::BUFFER_PARAM_DEFAULTS.merge(options)

      cast_geometry_ptr(
        FFIGeos.GEOSOffsetCurve_r(
          Geos.current_handle_pointer,
          ptr,
          width,
          options[:quad_segs],
          options[:join],
          options[:mitre_limit]
        ),
        srid_copy: srid
      )
    end

    if FFIGeos.respond_to?(:GEOSisClosed_r)
      def closed?
        bool_result(FFIGeos.GEOSisClosed_r(Geos.current_handle_pointer, ptr))
      end
    end

    def to_linear_ring
      return Geos.create_linear_ring(coord_seq, srid: pick_srid_according_to_policy(srid)) if closed?

      self_cs = coord_seq.to_a
      self_cs.push(self_cs[0])

      Geos.create_linear_ring(self_cs, srid: pick_srid_according_to_policy(srid))
    end

    def to_polygon
      to_linear_ring.to_polygon
    end

    def dump_points(cur_path = [])
      cur_path.concat(to_a)
    end

    def snap_to_grid!(*args, **)
      unless empty?
        cs = coord_seq.snap_to_grid!(*args)

        if cs.empty?
          @ptr = Geos.create_empty_line_string(srid: srid).ptr
        elsif cs.length <= 1
          raise Geos::InvalidGeometryError, "snap_to_grid! produced an invalid number of points in for a LineString - found #{cs.length} - must be 0 or > 1"
        else
          @ptr = Geos.create_line_string(cs).ptr
        end
      end

      self
    end

    def snap_to_grid(*args, **)
      ret = dup.snap_to_grid!(*args)
      ret.srid = pick_srid_according_to_policy(srid)
      ret
    end

    def line_interpolate_point(fraction)
      raise ArgumentError, 'fraction must be between 0 and 1' unless fraction.between?(0, 1)

      case fraction
        when 0
          start_point
        when 1
          end_point
        else
          length = self.length
          total_length = 0
          segs = num_points - 1

          segs.times do |i|
            p_1 = self[i]
            p_2 = self[i + 1]

            seg_length = p_1.distance(p_2) / length

            if fraction < total_length + seg_length
              dseg = (fraction - total_length) / seg_length

              args = []
              args << (p_1.x + ((p_2.x - p_1.x) * dseg))
              args << (p_1.y + ((p_2.y - p_1.y) * dseg))
              args << (p_1.z + ((p_2.z - p_1.z) * dseg)) if has_z?

              args << { srid: pick_srid_according_to_policy(srid) } unless srid.zero?

              return Geos.create_point(*args)
            end

            total_length += seg_length
          end

          # if all else fails...
          end_point
      end
    end
    alias interpolate_point line_interpolate_point

    %w{ max min }.each do |op|
      %w{ x y }.each do |dimension|
        native_method = "GEOSGeom_get#{dimension.upcase}#{op[0].upcase}#{op[1..]}_r"

        if FFIGeos.respond_to?(native_method)
          class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
            def #{dimension}_#{op}
              return if empty?

              double_ptr = FFI::MemoryPointer.new(:double)
              FFIGeos.#{native_method}(Geos.current_handle_pointer, ptr, double_ptr)
              double_ptr.read_double
            end
          RUBY
        else
          class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
            def #{dimension}_#{op}
              unless self.empty?
                self.coord_seq.#{dimension}_#{op}
              end
            end
          RUBY
        end
      end

      class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
        def z_#{op}
          unless self.empty?
            if self.has_z?
              self.coord_seq.z_#{op}
            else
              0
            end
          end
        end
      RUBY
    end

    %w{
      affine
      rotate
      rotate_x
      rotate_y
      rotate_z
      scale
      trans_scale
      translate
    }.each do |m|
      class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
        def #{m}!(*args, **kwargs)
          unless self.empty?
            self.coord_seq.#{m}!(*args, **kwargs)
          end

          self
        end

        def #{m}(*args, **kwargs)
          ret = self.dup.#{m}!(*args, **kwargs)
          ret.srid = pick_srid_according_to_policy(self.srid)
          ret
        end
      RUBY
    end
  end
end
