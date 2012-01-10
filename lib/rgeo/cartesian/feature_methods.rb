# -----------------------------------------------------------------------------
#
# Cartesian common methods
#
# -----------------------------------------------------------------------------
# Copyright 2010-2012 Daniel Azuma
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


    module GeometryMethods  # :nodoc:


      def srid
        factory.srid
      end


      def envelope
        BoundingBox.new(factory).add(self).to_geometry
      end


    end


    module PointMethods  # :nodoc:


      def distance(rhs_)
        rhs_ = ::RGeo::Feature.cast(rhs_, @factory)
        case rhs_
        when PointImpl
          dx_ = @x - rhs_.x
          dy_ = @y - rhs_.y
          ::Math.sqrt(dx_ * dx_ + dy_ * dy_)
        else
          super
        end
      end


    end


    module LineStringMethods  # :nodoc:


      def _segments
        unless @segments
          @segments = (0..num_points-2).map do |i_|
            Segment.new(point_n(i_), point_n(i_+1))
          end
        end
        @segments
      end


      def is_simple?
        segs_ = _segments
        len_ = segs_.length
        return false if segs_.any?{ |a_| a_.degenerate? }
        return true if len_ == 1
        return segs_[0].s != segs_[1].e if len_ == 2
        segs_.each_with_index do |seg_, index_|
          nindex_ = index_ + 1
          nindex_ = nil if nindex_ == len_
          return false if nindex_ && seg_.contains_point?(segs_[nindex_].e)
          pindex_ = index_ - 1
          pindex_ = nil if pindex_ < 0
          return false if pindex_ && seg_.contains_point?(segs_[pindex_].s)
          if nindex_
            oindex_ = nindex_ + 1
            while oindex_ < len_
              oseg_ = segs_[oindex_]
              return false if !(index_ == 0 && oindex_ == len_-1 && seg_.s == oseg_.e) && seg_.intersects_segment?(oseg_)
              oindex_ += 1
            end
          end
        end
        true
      end


      def length
        @segments.inject(0.0){ |sum_, seg_| sum_ + seg_.length }
      end


    end

  end

end
