# -----------------------------------------------------------------------------
#
# Projtected geographic feature classes
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


    class ProjectedPointImpl  # :nodoc:


      include Feature::Point
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicPointMethods
      include ProjectedGeometryMethods


      def _validate_geometry
        @y = 85.0511287 if @y > 85.0511287
        @y = -85.0511287 if @y < -85.0511287
        super
      end


      def canonical_x
        x_ = @x % 360.0
        x_ -= 360.0 if x_ >= 180.0
        x_
      end
      alias_method :canonical_longitude, :canonical_x
      alias_method :canonical_lon, :canonical_x


      def canonical_point
        if @x >= -180.0 && @x < 180.0
          self
        else
          PointImpl.new(@factory, canonical_x, @y)
        end
      end


      alias_method :longitude, :x
      alias_method :lon, :x
      alias_method :latitude, :y
      alias_method :lat, :y


      Feature::MixinCollection::GLOBAL.for_type(Feature::Point).include_in_class(self, true)


    end


    class ProjectedLineStringImpl  # :nodoc:


      include Feature::LineString
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicLineStringMethods
      include ProjectedGeometryMethods
      include ProjectedNCurveMethods
      include ProjectedLineStringMethods


      Feature::MixinCollection::GLOBAL.for_type(Feature::LineString).include_in_class(self, true)


    end


    class ProjectedLinearRingImpl  # :nodoc:


      include Feature::LinearRing
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicLineStringMethods
      include ImplHelper::BasicLinearRingMethods
      include ProjectedGeometryMethods
      include ProjectedNCurveMethods
      include ProjectedLineStringMethods


      Feature::MixinCollection::GLOBAL.for_type(Feature::LinearRing).include_in_class(self, true)


    end


    class ProjectedLineImpl  # :nodoc:


      include Feature::Line
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicLineStringMethods
      include ImplHelper::BasicLineMethods
      include ProjectedGeometryMethods
      include ProjectedNCurveMethods
      include ProjectedLineStringMethods


      Feature::MixinCollection::GLOBAL.for_type(Feature::Line).include_in_class(self, true)


    end


    class ProjectedPolygonImpl  # :nodoc:


      include Feature::Polygon
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicPolygonMethods
      include ProjectedGeometryMethods
      include ProjectedNSurfaceMethods


      def _validate_geometry
        super
        unless projection
          raise Error::InvalidGeometry, 'Polygon failed assertions'
        end
      end


      Feature::MixinCollection::GLOBAL.for_type(Feature::Polygon).include_in_class(self, true)


    end


    class ProjectedGeometryCollectionImpl  # :nodoc:


      include Feature::GeometryCollection
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicGeometryCollectionMethods
      include ProjectedGeometryMethods


      Feature::MixinCollection::GLOBAL.for_type(Feature::GeometryCollection).include_in_class(self, true)


    end


    class ProjectedMultiPointImpl  # :nodoc:


      include Feature::MultiPoint
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicGeometryCollectionMethods
      include ImplHelper::BasicMultiPointMethods
      include ProjectedGeometryMethods


      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiPoint).include_in_class(self, true)


    end


    class ProjectedMultiLineStringImpl  # :nodoc:


      include Feature::MultiLineString
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicGeometryCollectionMethods
      include ImplHelper::BasicMultiLineStringMethods
      include ProjectedGeometryMethods
      include ProjectedNCurveMethods


      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiLineString).include_in_class(self, true)


    end


    class ProjectedMultiPolygonImpl  # :nodoc:


      include Feature::MultiPolygon
      include ImplHelper::BasicGeometryMethods
      include ImplHelper::BasicGeometryCollectionMethods
      include ImplHelper::BasicMultiPolygonMethods
      include ProjectedGeometryMethods
      include ProjectedNSurfaceMethods


      def _validate_geometry
        super
        unless projection
          raise Error::InvalidGeometry, 'MultiPolygon failed assertions'
        end
      end


      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiPolygon).include_in_class(self, true)


    end


  end

end
