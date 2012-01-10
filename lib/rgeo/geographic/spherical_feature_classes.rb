# -----------------------------------------------------------------------------
#
# Spherical geographic feature classes
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


    class SphericalPointImpl  # :nodoc:


      include Feature::Point
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicPointMethods
      include SphericalGeometryMethods


      def _validate_geometry
        @x = @x % 360.0
        @x -= 360.0 if @x >= 180.0
        @y = 90.0 if @y > 90.0
        @y = -90.0 if @y < -90.0
        super
      end


      def _xyz
        @xyz ||= SphericalMath::PointXYZ.from_latlon(@y, @x)
      end


      def distance(rhs_)
        rhs_ = Feature.cast(rhs_, @factory)
        case rhs_
        when SphericalPointImpl
          _xyz.dist_to_point(rhs_._xyz) * SphericalMath::RADIUS
        else
          super
        end
      end


      def equals?(rhs_)
        return false unless rhs_.is_a?(self.class) && rhs_.factory == self.factory
        case rhs_
        when Feature::Point
          if @y == 90
            rhs_.y == 90
          elsif @y == -90
            rhs_.y == -90
          else
            rhs_.x == @x && rhs_.y == @y
          end
        when Feature::LineString
          rhs_.num_points > 0 && rhs_.points.all?{ |elem_| equals?(elem_) }
        when Feature::GeometryCollection
          rhs_.num_geometries > 0 && rhs_.all?{ |elem_| equals?(elem_) }
        else
          false
        end
      end


      alias_method :longitude, :x
      alias_method :lon, :x
      alias_method :latitude, :y
      alias_method :lat, :y


      Feature::MixinCollection::GLOBAL.for_type(Feature::Point).include_in_class(self, true)


    end


    class SphericalLineStringImpl  # :nodoc:


      include Feature::LineString
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicLineStringMethods
      include SphericalGeometryMethods
      include SphericalLineStringMethods


      Feature::MixinCollection::GLOBAL.for_type(Feature::LineString).include_in_class(self, true)


    end


    class SphericalLineImpl  # :nodoc:


      include Feature::Line
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicLineStringMethods
      include ImplHelper::BasicLineMethods
      include SphericalGeometryMethods
      include SphericalLineStringMethods


      Feature::MixinCollection::GLOBAL.for_type(Feature::Line).include_in_class(self, true)


    end


    class SphericalLinearRingImpl  # :nodoc:


      include Feature::LinearRing
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicLineStringMethods
      include ImplHelper::BasicLinearRingMethods
      include SphericalGeometryMethods
      include SphericalLineStringMethods


      Feature::MixinCollection::GLOBAL.for_type(Feature::LinearRing).include_in_class(self, true)


    end


    class SphericalPolygonImpl  # :nodoc:


      include Feature::Polygon
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicPolygonMethods
      include SphericalGeometryMethods


      Feature::MixinCollection::GLOBAL.for_type(Feature::Polygon).include_in_class(self, true)


    end


    class SphericalGeometryCollectionImpl  # :nodoc:


      include Feature::GeometryCollection
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicGeometryCollectionMethods
      include SphericalGeometryMethods


      Feature::MixinCollection::GLOBAL.for_type(Feature::GeometryCollection).include_in_class(self, true)


    end


    class SphericalMultiPointImpl  # :nodoc:


      include Feature::MultiPoint
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicGeometryCollectionMethods
      include ImplHelper::BasicMultiPointMethods
      include SphericalGeometryMethods


      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiPoint).include_in_class(self, true)


    end


    class SphericalMultiLineStringImpl  # :nodoc:


      include Feature::MultiLineString
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicGeometryCollectionMethods
      include ImplHelper::BasicMultiLineStringMethods
      include SphericalGeometryMethods


      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiLineString).include_in_class(self, true)


    end


    class SphericalMultiPolygonImpl  # :nodoc:


      include Feature::MultiPolygon
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicGeometryCollectionMethods
      include ImplHelper::BasicMultiPolygonMethods
      include SphericalGeometryMethods


      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiPolygon).include_in_class(self, true)


    end


  end

end
