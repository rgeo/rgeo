# -----------------------------------------------------------------------------
#
# Projected geographic common method definitions
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

  module Geographic


    module ProjectedGeometryMethods  # :nodoc:


      def srid
        factory.srid
      end


      def projection
        unless defined?(@projection)
          @projection = factory.project(self)
        end
        @projection
      end


      def envelope
        factory.unproject(projection.envelope)
      end


      def is_empty?
        projection.is_empty?
      end


      def is_simple?
        projection.is_simple?
      end


      def boundary
        boundary_ = projection.boundary
        boundary_ ? factory.unproject(boundary_) : nil
      end


      def equals?(rhs_)
        projection.equals?(Feature.cast(rhs_, factory).projection)
      end


      def disjoint?(rhs_)
        projection.disjoint?(Feature.cast(rhs_, factory).projection)
      end


      def intersects?(rhs_)
        projection.intersects?(Feature.cast(rhs_, factory).projection)
      end


      def touches?(rhs_)
        projection.touches?(Feature.cast(rhs_, factory).projection)
      end


      def crosses?(rhs_)
        projection.crosses?(Feature.cast(rhs_, factory).projection)
      end


      def within?(rhs_)
        projection.within?(Feature.cast(rhs_, factory).projection)
      end


      def contains?(rhs_)
        projection.contains?(Feature.cast(rhs_, factory).projection)
      end


      def overlaps?(rhs_)
        projection.overlaps?(Feature.cast(rhs_, factory).projection)
      end


      def relate(rhs_, pattern_)
        projection.relate(Feature.cast(rhs_, factory).projection, pattern_)
      end


      def distance(rhs_)
        projection.distance(Feature.cast(rhs_, factory).projection)
      end


      def buffer(distance_)
        factory.unproject(projection.buffer(distance_))
      end


      def convex_hull
        factory.unproject(projection.convex_hull)
      end


      def intersection(rhs_)
        factory.unproject(projection.intersection(Feature.cast(rhs_, factory).projection))
      end


      def union(rhs_)
        factory.unproject(projection.union(Feature.cast(rhs_, factory).projection))
      end


      def difference(rhs_)
        factory.unproject(projection.difference(Feature.cast(rhs_, factory).projection))
      end


      def sym_difference(rhs_)
        factory.unproject(projection.sym_difference(Feature.cast(rhs_, factory).projection))
      end


    end


    module ProjectedNCurveMethods  # :nodoc:


      def length
        projection.length
      end


    end


    module ProjectedLineStringMethods  # :nodoc:


      def _validate_geometry
        size_ = @points.size
        if size_ > 1
          last_ = @points[0]
          (1...size_).each do |i_|
            p_ = @points[i_]
            last_x_ = last_.x
            p_x_ = p_.x
            changed_ = true
            if p_x_ < last_x_ - 180.0
              p_x_ += 360.0 while p_x_ < last_x_ - 180.0
            elsif p_x_ > last_x_ + 180.0
              p_x_ -= 360.0 while p_x_ > last_x_ + 180.0
            else
              changed_ = false
            end
            if changed_
              p_ = factory.point(p_x_, p_.y)
              @points[i_] = p_
            end
            last_ = p_
          end
        end
        super
      end


    end


    module ProjectedNSurfaceMethods  # :nodoc:


      def area
        projection.area
      end


      def centroid
        factory.unproject(projection.centroid)
      end


      def point_on_surface
        factory.unproject(projection.point_on_surface)
      end


    end


  end

end
