# -----------------------------------------------------------------------------
# 
# Core calculations in the plane
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
  
  module Cartesian
    
    
    # Represents a line segment in the plane.
    
    class Segment
      
      def initialize(start_, end_)
        @s = start_
        @e = end_
        @sx = @s.x
        @sy = @s.y
        @ex = @e.x
        @ey = @e.y
        @dx = @ex - @sx
        @dy = @ey - @sy
        @lensq = @dx * @dx + @dy * @dy
      end
      
      
      attr_reader :s
      attr_reader :e
      attr_reader :dx
      attr_reader :dy
      
      
      def to_s
        "#{@s} - #{@e}"
      end
      
      
      def eql?(rhs_)
        rhs_.kind_of?(Segment) && @s == rhs_.s && @e == rhs_.e
      end
      alias_method :==, :eql?
      
      
      def degenerate?
        @lensq == 0
      end
      
      
      def side(p_)
        px_ = p_.x
        py_ = p_.y
        (@sx - px_) * (@ey - py_) - (@sy - py_) * (@ex - px_)
      end
      
      
      def tproj(p_)
        if @lensq == 0
          nil
        else
          px_ = @sx - p_.x
          py_ = @sy - p_.y
          - (@dx * px_ + @dy * py_) / @lensq
        end
      end
      
      
      def contains_point?(p_)
        if side(p_) == 0
          t_ = tproj(p_)
          t_ && t_ >= 0.0 && t_ <= 1.0
        else
          false
        end
      end
      
      
      def intersects_segment?(seg_)
        s2_ = seg_.s
        sx2_ = s2_.x
        sy2_ = s2_.y
        dx2_ = seg_.dx
        dy2_ = seg_.dy
        denom_ = @dx*dy2_ - @dy*dx2_
        return side(s2_) == 0 if denom_ == 0
        t_ = (dy2_ * (sx2_ - @sx) + dx2_ * (@sy - sy2_)) / denom_
        return false if t_ < 0.0 || t_ > 1.0
        t2_ = (@dy * (sx2_ - @sx) + @dx * (@sy - sy2_)) / denom_
        t2_ >= 0.0 && t2_ <= 1.0
      end
      
      
    end
    
    
    module Calculations
    end
    
    
  end
  
end
