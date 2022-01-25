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
      points = [ exterior_ring.dump_points ]

      interior_rings.each do |ring|
        points.push(ring.dump_points)
      end

      cur_path.concat(points)
    end

    def snap_to_grid!(*args)
      if !self.empty?
        exterior_ring = self.exterior_ring.coord_seq.snap_to_grid!(*args)

        if exterior_ring.length == 0
          @ptr = Geos.create_empty_polygon(:srid => self.srid).ptr
        elsif exterior_ring.length < 4
          raise Geos::InvalidGeometryError.new("snap_to_grid! produced an invalid number of points in exterior ring - found #{exterior_ring.length} - must be 0 or >= 4")
        else
          interior_rings = []

          self.num_interior_rings.times { |i|
            interior_ring = self.interior_ring_n(i).coord_seq.snap_to_grid!(*args)

            interior_rings << interior_ring unless interior_ring.length < 4
          }

          interior_rings.compact!

          polygon = Geos.create_polygon(exterior_ring, interior_rings, :srid => self.srid)
          @ptr = polygon.ptr
        end
      end

      self
    end

    def snap_to_grid(*args)
      ret = self.dup.snap_to_grid!(*args)
      ret.srid = pick_srid_according_to_policy(self.srid)
      ret
    end

    %w{ max min }.each do |op|
      %w{ x y }.each do |dimension|
        self.class_eval(<<-EOF, __FILE__, __LINE__ + 1)
          def #{dimension}_#{op}
            unless self.empty?
              self.envelope.exterior_ring.#{dimension}_#{op}
            end
          end
        EOF
      end

      self.class_eval(<<-EOF, __FILE__, __LINE__ + 1)
        def z_#{op}
          unless self.empty?
            if self.has_z?
              self.exterior_ring.z_#{op}
            else
              0
            end
          end
        end
      EOF
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
      self.class_eval(<<-EOF, __FILE__, __LINE__ + 1)
        def #{m}!(*args)
          self.exterior_ring.coord_seq.#{m}!(*args)
          self.interior_rings.each do |ring|
            ring.coord_seq.#{m}!(*args)
          end
          self
        end

        def #{m}(*args)
          ret = self.dup.#{m}!(*args)
          ret.srid = pick_srid_according_to_policy(self.srid)
          ret
        end
      EOF
    end
  end
end
