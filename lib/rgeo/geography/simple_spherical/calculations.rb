# -----------------------------------------------------------------------------
# 
# Core calculations on the sphere
# 
# -----------------------------------------------------------------------------
# Copyright 2010 Daniel Azuma
# 
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of the copyright holder, nor the names of any other
#   contributors to this software, may be used to endorse or promote products
#   derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
# -----------------------------------------------------------------------------
;


module RGeo
  
  module Geography
    
    module SimpleSpherical
      
      
      RADIUS = 6371007.2
      
      
      # Represents a point on the sphere in (x,y,z) coordinates instead
      # of lat-lon. This form is often faster, more convenient, and more
      # numerically stable for certain computations.
      # 
      # The coordinate system is a right-handed system where the z-axis
      # goes through the north pole, the x-axis goes through the prime
      # meridian, and the y-axis goes through +90 degrees longitude.
      # 
      # This object is also used to represent a great circle, as its axis
      # of rotation.
      
      class PointXYZ
        
        def initialize(x_, y_, z_)
          r_ = ::Math.sqrt(x_ * x_ + y_ * y_ + z_ * z_)
          @x = x_ / r_
          @y = y_ / r_
          @z = z_ / r_
        end
        
        
        attr_reader :x
        attr_reader :y
        attr_reader :z
        
        
        def latlon
          lat_rad_ = ::Math.asin(@z)
          lon_rad_ = ::Math.atan2(@y, @x) rescue 0.0
          rpd_ = Common::Helper::RADIANS_PER_DEGREE
          [lat_rad_ / rpd_, lon_rad_ / rpd_]
        end
        
        
        def *(rhs_)
          @x * rhs_.x + @y * rhs_.y + @z * rhs_.z
        end
        
        
        def %(rhs_)
          rx_ = rhs_.x
          ry_ = rhs_.y
          rz_ = rhs_.z
          PointXYZ.new(@y*rz_-@z*ry_, @z*rx_-@x*rz_, @x*ry_-@y-rx_) rescue nil
        end
        
        
        def self.from_latlon(lat_, lon_)
          rpd_ = Common::Helper::RADIANS_PER_DEGREE
          lat_rad_ = rpd_ * lat_
          lon_rad_ = rpd_ * lon_
          z_ = ::Math.sin(lat_rad_)
          r_ = ::Math.cos(lat_rad_)
          x_ = ::Math.cos(lon_rad_) * r_
          y_ = ::Math.sin(lon_rad_) * r_
          new(x_, y_, z_)
        end
        
      end
      
      
      module Calculations
        
        
        def point_distance(p1_, p2_)
          rpd_ = Common::Helper::RADIANS_PER_DEGREE
          from_lat_rad_ = rpd_ * from_.lat
          to_lat_rad_ = rpd_ * to_.lat
          delta_lon_rad_ = rpd_ * (to_.lon - from_.lon)
          val_ = ::Math.sin(from_lat_rad_) * ::Math.sin(to_lat_rad_) + 
            ::Math.cos(from_lat_rad_) * ::Math.cos(to_lat_rad_) * ::Math.cos(delta_lon_rad_)
          val_ = 1.0 if val_ > 1.0
          val_ = -1.0 if val_ < -1.0
          ::Math.acos(val_) * RADIUS
        end
        
        
      end
      
      
    end
    
  end
  
end
