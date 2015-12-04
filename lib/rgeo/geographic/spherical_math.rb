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
        def initialize(x_, y_, z_)
          r_ = ::Math.sqrt(x_ * x_ + y_ * y_ + z_ * z_)
          @x = (x_ / r_).to_f
          @y = (y_ / r_).to_f
          @z = (z_ / r_).to_f
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
        alias_method :==, :eql?

        def latlon
          lat_rad_ = ::Math.asin(@z)
          lon_rad_ = begin
                       ::Math.atan2(@y, @x)
                     rescue
                       0.0
                     end
          rpd_ = ImplHelper::Math::RADIANS_PER_DEGREE
          [lat_rad_ / rpd_, lon_rad_ / rpd_]
        end

        def lonlat
          lat_rad_ = ::Math.asin(@z)
          lon_rad_ = begin
                       ::Math.atan2(@y, @x)
                     rescue
                       0.0
                     end
          rpd_ = ImplHelper::Math::RADIANS_PER_DEGREE
          [lon_rad_ / rpd_, lat_rad_ / rpd_]
        end

        def *(rhs_)
          val_ = @x * rhs_.x + @y * rhs_.y + @z * rhs_.z
          val_ = 1.0 if val_ > 1.0
          val_ = -1.0 if val_ < -1.0
          val_
        end

        def %(rhs_)
          rx_ = rhs_.x
          ry_ = rhs_.y
          rz_ = rhs_.z
          begin
            PointXYZ.new(@y * rz_ - @z * ry_, @z * rx_ - @x * rz_, @x * ry_ - @y * rx_)
          rescue
            nil
          end
        end

        def dist_to_point(rhs_)
          rx_ = rhs_.x
          ry_ = rhs_.y
          rz_ = rhs_.z
          dot_ = @x * rx_ + @y * ry_ + @z * rz_
          if dot_ > -0.8 && dot_ < 0.8
            ::Math.acos(dot_)
          else
            x_ = @y * rz_ - @z * ry_
            y_ = @z * rx_ - @x * rz_
            z_ = @x * ry_ - @y * rx_
            as_ = ::Math.asin(::Math.sqrt(x_ * x_ + y_ * y_ + z_ * z_))
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

        def self.from_latlon(lat_, lon_)
          rpd_ = ImplHelper::Math::RADIANS_PER_DEGREE
          lat_rad_ = rpd_ * lat_
          lon_rad_ = rpd_ * lon_
          z_ = ::Math.sin(lat_rad_)
          r_ = ::Math.cos(lat_rad_)
          x_ = ::Math.cos(lon_rad_) * r_
          y_ = ::Math.sin(lon_rad_) * r_
          new(x_, y_, z_)
        end

        def self.weighted_combination(p1_, w1_, p2_, w2_)
          new(p1_.x * w1_ + p2_.x * w2_, p1_.y * w1_ + p2_.y * w2_, p1_.z * w1_ + p2_.z * w2_)
        end

        P1 = new(1, 0, 0)
        P2 = new(0, 1, 0)
      end

      # Represents a finite arc on the sphere.

      class ArcXYZ # :nodoc:
        def initialize(start_, end_)
          @s = start_
          @e = end_
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
        alias_method :==, :eql?

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
          my_axis_ = axis
          dot1_ = my_axis_ * obj_.s
          dot2_ = my_axis_ * obj_.e
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
