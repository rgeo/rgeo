# -----------------------------------------------------------------------------
#
# Common methods for Polygon features
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

  module ImplHelper  # :nodoc:


    module BasicPolygonMethods  # :nodoc:


      def initialize(factory_, exterior_ring_, interior_rings_)
        _set_factory(factory_)
        @exterior_ring = Feature.cast(exterior_ring_, factory_, Feature::LinearRing)
        unless @exterior_ring
          raise Error::InvalidGeometry, "Failed to cast exterior ring #{exterior_ring_}"
        end
        @interior_rings = (interior_rings_ || []).map do |elem_|
          elem_ = Feature.cast(elem_, factory_, Feature::LinearRing)
          unless elem_
            raise Error::InvalidGeometry, "Could not cast interior ring #{elem_}"
          end
          elem_
        end
        _validate_geometry
      end


      def exterior_ring
        @exterior_ring
      end


      def num_interior_rings
        @interior_rings.size
      end


      def interior_ring_n(n_)
        n_ < 0 ? nil : @interior_rings[n_]
      end


      def interior_rings
        @interior_rings.dup
      end


      def dimension
        2
      end


      def geometry_type
        Feature::Polygon
      end


      def is_empty?
        @exterior_ring.is_empty?
      end


      def boundary
        array_ = []
        unless @exterior_ring.is_empty?
          array_ << @exterior_ring
        end
        array_.concat(@interior_rings)
        factory.multi_line_string(array_)
      end


      def rep_equals?(rhs_)
        if rhs_.is_a?(self.class) && rhs_.factory.eql?(@factory) && @exterior_ring.rep_equals?(rhs_.exterior_ring) && @interior_rings.size == rhs_.num_interior_rings
          rhs_.interior_rings.each_with_index{ |r_, i_| return false unless @interior_rings[i_].rep_equals?(r_) }
        else
          false
        end
      end


    end


  end

end
