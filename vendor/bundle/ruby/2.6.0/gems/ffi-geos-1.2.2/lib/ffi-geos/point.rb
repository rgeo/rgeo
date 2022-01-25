# frozen_string_literal: true

module Geos
  class Point < Geometry
    if FFIGeos.respond_to?(:GEOSGeomGetX_r)
      def get_x
        double_ptr = FFI::MemoryPointer.new(:double)
        FFIGeos.GEOSGeomGetX_r(Geos.current_handle_pointer, ptr, double_ptr)
        double_ptr.read_double
      end
    else
      def get_x
        coord_seq.get_x(0)
      end
    end
    alias x get_x

    if FFIGeos.respond_to?(:GEOSGeomGetY_r)
      def get_y
        double_ptr = FFI::MemoryPointer.new(:double)
        FFIGeos.GEOSGeomGetY_r(Geos.current_handle_pointer, ptr, double_ptr)
        double_ptr.read_double
      end
    else
      def get_y
        coord_seq.get_y(0)
      end
    end
    alias y get_y

    if FFIGeos.respond_to?(:GEOSGeomGetZ_r)
      def get_z
        double_ptr = FFI::MemoryPointer.new(:double)
        FFIGeos.GEOSGeomGetZ_r(Geos.current_handle_pointer, ptr, double_ptr)
        double_ptr.read_double
      end
    else
      def get_z
        coord_seq.get_z(0)
      end
    end
    alias z get_z

    def area
      0
    end

    def length
      0
    end

    def num_geometries
      1
    end

    def num_coordinates
      1
    end

    def normalize!
      self
    end
    alias normalize normalize!

    %w{
      convex_hull
      point_on_surface
      centroid
      envelope
      topology_preserve_simplify
    }.each do |method|
      class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
        def #{method}(*args)
          dup.tap do |ret|
            ret.srid = pick_srid_according_to_policy(ret.srid)
          end
        end
      RUBY
    end

    def dump_points(cur_path = [])
      cur_path.push(self.dup)
    end

    %w{ max min }.each do |op|
      %w{ x y }.each do |dimension|
        self.class_eval(<<-EOF, __FILE__, __LINE__ + 1)
          def #{dimension}_#{op}
            unless self.empty?
              self.#{dimension}
            end
          end
        EOF
      end

      self.class_eval(<<-EOF, __FILE__, __LINE__ + 1)
        def z_#{op}
          unless self.empty?
            if self.has_z?
              self.z
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
      snap_to_grid
      trans_scale
      translate
    }.each do |m|
      self.class_eval(<<-EOF, __FILE__, __LINE__ + 1)
        def #{m}!(*args)
          unless self.empty?
            self.coord_seq.#{m}!(*args)
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
