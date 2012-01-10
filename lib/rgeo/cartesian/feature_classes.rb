# -----------------------------------------------------------------------------
#
# Cartesian feature classes
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


    class PointImpl  # :nodoc:


      include ::RGeo::Feature::Point
      include ::RGeo::ImplHelper::BasicGeometryMethods
      include ::RGeo::ImplHelper::BasicPointMethods
      include ::RGeo::Cartesian::GeometryMethods
      include ::RGeo::Cartesian::PointMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Point).include_in_class(self, true)


    end


    class LineStringImpl  # :nodoc:


      include ::RGeo::Feature::LineString
      include ::RGeo::ImplHelper::BasicGeometryMethods
      include ::RGeo::ImplHelper::BasicLineStringMethods
      include ::RGeo::Cartesian::GeometryMethods
      include ::RGeo::Cartesian::LineStringMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::LineString).include_in_class(self, true)


    end


    class LineImpl  # :nodoc:


      include ::RGeo::Feature::Line
      include ::RGeo::ImplHelper::BasicGeometryMethods
      include ::RGeo::ImplHelper::BasicLineStringMethods
      include ::RGeo::ImplHelper::BasicLineMethods
      include ::RGeo::Cartesian::GeometryMethods
      include ::RGeo::Cartesian::LineStringMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Line).include_in_class(self, true)


    end


    class LinearRingImpl  # :nodoc:


      include ::RGeo::Feature::LinearRing
      include ::RGeo::ImplHelper::BasicGeometryMethods
      include ::RGeo::ImplHelper::BasicLineStringMethods
      include ::RGeo::ImplHelper::BasicLinearRingMethods
      include ::RGeo::Cartesian::GeometryMethods
      include ::RGeo::Cartesian::LineStringMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::LinearRing).include_in_class(self, true)


    end


    class PolygonImpl  # :nodoc:


      include ::RGeo::Feature::Polygon
      include ::RGeo::ImplHelper::BasicGeometryMethods
      include ::RGeo::ImplHelper::BasicPolygonMethods
      include ::RGeo::Cartesian::GeometryMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Polygon).include_in_class(self, true)


    end


    class GeometryCollectionImpl  # :nodoc:


      include ::RGeo::Feature::GeometryCollection
      include ::RGeo::ImplHelper::BasicGeometryMethods
      include ::RGeo::ImplHelper::BasicGeometryCollectionMethods
      include ::RGeo::Cartesian::GeometryMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::GeometryCollection).include_in_class(self, true)


    end


    class MultiPointImpl  # :nodoc:


      include ::RGeo::Feature::MultiPoint
      include ::RGeo::ImplHelper::BasicGeometryMethods
      include ::RGeo::ImplHelper::BasicGeometryCollectionMethods
      include ::RGeo::ImplHelper::BasicMultiPointMethods
      include ::RGeo::Cartesian::GeometryMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiPoint).include_in_class(self, true)


    end


    class MultiLineStringImpl  # :nodoc:


      include ::RGeo::Feature::MultiLineString
      include ::RGeo::ImplHelper::BasicGeometryMethods
      include ::RGeo::ImplHelper::BasicGeometryCollectionMethods
      include ::RGeo::ImplHelper::BasicMultiLineStringMethods
      include ::RGeo::Cartesian::GeometryMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiLineString).include_in_class(self, true)


    end


    class MultiPolygonImpl  # :nodoc:


      include ::RGeo::Feature::MultiPolygon
      include ::RGeo::ImplHelper::BasicGeometryMethods
      include ::RGeo::ImplHelper::BasicGeometryCollectionMethods
      include ::RGeo::ImplHelper::BasicMultiPolygonMethods
      include ::RGeo::Cartesian::GeometryMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiPolygon).include_in_class(self, true)


    end


  end

end
