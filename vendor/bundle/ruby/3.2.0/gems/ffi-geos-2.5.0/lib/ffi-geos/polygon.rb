# frozen_string_literal: true

module Geos
  class Polygon < Geometry
    def num_interior_rings
      FFIGeos.GEOSGetNumInteriorRings_r(Geos.current_handle_pointer, ptr)
    end

    def interior_ring_n(n)
      raise Geos::IndexBoundsError if n.negative? || n >= num_interior_rings

      cast_geometry_ptr(
        FFIGeos.GEOSGetInteriorRingN_r(Geos.current_handle_pointer, ptr, n),
        auto_free: false,
        srid_copy: srid,
        parent: self
      )
    end
    alias interior_ring interior_ring_n

    def exterior_ring
      cast_geometry_ptr(
        FFIGeos.GEOSGetExteriorRing_r(Geos.current_handle_pointer, ptr),
        auto_free: false,
        srid_copy: srid,
        parent: self
      )
    end

    def interior_rings
      num_interior_rings.times.collect do |n|
        interior_ring_n(n)
      end
    end

    def dump_points(cur_path = [])
      points = [exterior_ring.dump_points]

      interior_rings.each do |ring|
        points.push(ring.dump_points)
      end

      cur_path.concat(points)
    end

    def snap_to_grid!(*args)
      unless empty?
        exterior_ring = self.exterior_ring.coord_seq.snap_to_grid!(*args)

        if exterior_ring.empty?
          @ptr = Geos.create_empty_polygon(srid: srid).ptr
        elsif exterior_ring.length < 4
          raise Geos::InvalidGeometryError, "snap_to_grid! produced an invalid number of points in exterior ring - found #{exterior_ring.length} - must be 0 or >= 4"
        else
          interior_rings = []

          num_interior_rings.times do |i|
            interior_ring = interior_ring_n(i).coord_seq.snap_to_grid!(*args)

            interior_rings << interior_ring unless interior_ring.length < 4
          end

          interior_rings.compact!

          polygon = Geos.create_polygon(exterior_ring, interior_rings, srid: srid)
          @ptr = polygon.ptr
        end
      end

      self
    end

    def snap_to_grid(*args)
      ret = dup.snap_to_grid!(*args)
      ret.srid = pick_srid_according_to_policy(srid)
      ret
    end

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
              unless empty?
                envelope.exterior_ring.#{dimension}_#{op}
              end
            end
          RUBY
        end
      end

      class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
        def z_#{op}
          unless empty?
            if has_z?
              exterior_ring.z_#{op}
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
          exterior_ring.coord_seq.#{m}!(*args, **kwargs)
          interior_rings.each do |ring|
            ring.coord_seq.#{m}!(*args)
          end
          self
        end

        def #{m}(*args, **kwargs)
          ret = dup.#{m}!(*args, **kwargs)
          ret.srid = pick_srid_according_to_policy(srid)
          ret
        end
      RUBY
    end
  end
end
