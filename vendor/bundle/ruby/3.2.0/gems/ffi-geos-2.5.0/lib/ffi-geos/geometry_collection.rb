# frozen_string_literal: true

module Geos
  class GeometryCollection < Geometry
    include Enumerable

    # Yields each Geometry in the GeometryCollection.
    def each
      if block_given?
        num_geometries.times do |n|
          yield get_geometry_n(n)
        end
        self
      else
        num_geometries.times.collect { |n|
          get_geometry_n(n)
        }.to_enum
      end
    end

    def get_geometry_n(n)
      if n.negative? || n >= num_geometries
        nil
      else
        cast_geometry_ptr(FFIGeos.GEOSGetGeometryN_r(Geos.current_handle_pointer, ptr, n), auto_free: false)
      end
    end
    alias geometry_n get_geometry_n

    def [](*args)
      if args.length == 1 && args.first.is_a?(Numeric) && args.first >= 0
        get_geometry_n(args.first)
      else
        to_a[*args]
      end
    end
    alias slice []
    alias at []

    def dump_points(cur_path = [])
      each do |geom|
        cur_path << geom.dump_points
      end
      cur_path
    end

    %w{ x y z }.each do |dimension|
      %w{ max min }.each do |op|
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
                self.collect(&:#{dimension}_#{op}).#{op}
              end
            end
          RUBY
        end
      end
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
      class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
        def #{m}!(*args, **kwargs)
          unless self.empty?
            self.num_geometries.times do |i|
              self[i].#{m}!(*args, **kwargs)
            end
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
