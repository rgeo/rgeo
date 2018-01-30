# -----------------------------------------------------------------------------
#
# Core calculations on the sphere
#
# -----------------------------------------------------------------------------

module RGeo
  module Geographic
    module SphericalMath # :nodoc:
      RADIUS = 6_378_137.0

      # Represents a point on the unit sphere in (x,y,z) coordinates
      # instead of lat-lon. This form is often faster, more convenient,
      # and more numerically stable for certain computations.
      #
      # The coordinate system is a right-handed system where the z-axis
      # goes through the north pole, the x-axis goes through the prime
      # meridian, and the y-axis goes through +90 degrees longitude.
      #
      # This object is also used to represent a great circle, as its axis
      # of rotation.

      class PointXYZ # :nodoc:
        def initialize(x, y, z)
          r = ::Math.sqrt(x * x + y * y + z * z)
          @x = (x / r).to_f
          @y = (y / r).to_f
          @z = (z / r).to_f
          raise "Not a number" if @x.nan? || @y.nan? || @z.nan?
        end

        def to_s
          "(#{@x}, #{@y}, #{@z})"
        end

        attr_reader :x
        attr_reader :y
        attr_reader :z

        def eql?(rhs_)
          rhs_.is_a?(PointXYZ) && @x == rhs_.x && @y == rhs_.y && @z == rhs_.z
        end
        alias == eql?

        def latlon
          lat_rad = ::Math.asin(@z)
          lon_rad = begin
                       ::Math.atan2(@y, @x)
                     rescue
                       0.0
                     end
          rpd_ = ImplHelper::Math::RADIANS_PER_DEGREE
          [lat_rad / rpd_, lon_rad / rpd_]
        end

        def lonlat
          lat_rad = ::Math.asin(@z)
          lon_rad = begin
                       ::Math.atan2(@y, @x)
                     rescue
                       0.0
                     end
          rpd_ = ImplHelper::Math::RADIANS_PER_DEGREE
          [lon_rad / rpd_, lat_rad / rpd_]
        end

        def *(rhs_)
          val_ = @x * rhs_.x + @y * rhs_.y + @z * rhs_.z
          val_ = 1.0 if val_ > 1.0
          val_ = -1.0 if val_ < -1.0
          val_
        end

        def %(rhs_)
          rx = rhs_.x
          ry = rhs_.y
          rz = rhs_.z
          begin
            PointXYZ.new(@y * rz - @z * ry, @z * rx - @x * rz, @x * ry - @y * rx)
          rescue
            nil
          end
        end

        def dist_to_point(rhs_)
          rx = rhs_.x
          ry = rhs_.y
          rz = rhs_.z
          dot_ = @x * rx + @y * ry + @z * rz
          if dot_ > -0.8 && dot_ < 0.8
            ::Math.acos(dot_)
          else
            x = @y * rz - @z * ry
            y = @z * rx - @x * rz
            z = @x * ry - @y * rx
            as_ = ::Math.asin(::Math.sqrt(x * x + y * y + z * z))
            dot_ > 0.0 ? as_ : ::Math::PI - as_
          end
        end

        # Creates some point that is perpendicular to this point

        def create_perpendicular
          p1dot_ = self * P1
          p2dot_ = self * P2
          p1dot_ = -p1dot_ if p1dot_ < 0
          p2dot_ = -p2dot_ if p2dot_ < 0
          p1dot_ < p2dot_ ? (self % P1) : (self % P2)
        end

        def self.from_latlon(lat, lon)
          rpd_ = ImplHelper::Math::RADIANS_PER_DEGREE
          lat_rad = rpd_ * lat
          lon_rad = rpd_ * lon
          z = ::Math.sin(lat_rad)
          r = ::Math.cos(lat_rad)
          x = ::Math.cos(lon_rad) * r
          y = ::Math.sin(lon_rad) * r
          new(x, y, z)
        end

        def self.weighted_combination(p1, w1, p2, w2)
          new(p1.x * w1 + p2.x * w2, p1.y * w1 + p2.y * w2, p1.z * w1 + p2.z * w2)
        end

        P1 = new(1, 0, 0)
        P2 = new(0, 1, 0)
      end

      # Represents a finite arc on the sphere.

      class ArcXYZ # :nodoc:
        def initialize(start, stop)
          @s = start
          @e = stop
          @axis = false
        end

        attr_reader :s
        attr_reader :e

        def to_s
          "#{@s} - #{@e}"
        end

        def eql?(rhs_)
          rhs_.is_a?(ArcXYZ) && @s == rhs_.s && @e == rhs_.e
        end
        alias == eql?

        def degenerate?
          axis_ = axis
          axis_.x == 0 && axis_.y == 0 && axis_.z == 0
        end

        def axis
          @axis = @s % @e if @axis == false
          @axis
        end

        def contains_point?(obj_)
          axis_ = axis
          saxis_ = ArcXYZ.new(@s, obj_).axis
          eaxis_ = ArcXYZ.new(obj_, @e).axis
          !saxis_ || !eaxis_ || obj_ * axis_ == 0.0 && saxis_ * axis_ > 0 && eaxis_ * axis_ > 0
        end

        def intersects_arc?(obj_)
          myaxis_ = axis
          dot1_ = myaxis_ * obj_.s
          dot2_ = myaxis_ * obj_.e
          if dot1_ >= 0.0 && dot2_ <= 0.0 || dot1_ <= 0.0 && dot2_ >= 0.0
            ob_axis_ = obj_.axis
            dot1_ = ob_axis_ * @s
            dot2_ = ob_axis_ * @e
            dot1_ >= 0.0 && dot2_ <= 0.0 || dot1_ <= 0.0 && dot2_ >= 0.0
          else
            false
          end
        end

        def length
          @s.dist_to_point(@e)
        end
      end
    end
  end
end
