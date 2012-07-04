# -----------------------------------------------------------------------------
#
# GEOS implementation additions written in Ruby
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

  module Geos


    class ZMPointImpl  # :nodoc:


      include ZMGeometryMethods
      include ZMPointMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Point).include_in_class(self, true)


    end


    class ZMLineStringImpl  # :nodoc:


      include ZMGeometryMethods
      include ZMLineStringMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::LineString).include_in_class(self, true)


    end


    class ZMLinearRingImpl  # :nodoc:


      include ZMGeometryMethods
      include ZMLineStringMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::LinearRing).include_in_class(self, true)


    end


    class ZMLineImpl  # :nodoc:


      include ZMGeometryMethods
      include ZMLineStringMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Line).include_in_class(self, true)


    end


    class ZMPolygonImpl  # :nodoc:


      include ZMGeometryMethods
      include ZMPolygonMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Polygon).include_in_class(self, true)


    end


    class ZMGeometryCollectionImpl  # :nodoc:


      include ZMGeometryMethods
      include ZMGeometryCollectionMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::GeometryCollection).include_in_class(self, true)


    end


    class ZMMultiPointImpl  # :nodoc:


      include ZMGeometryMethods
      include ZMGeometryCollectionMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiPoint).include_in_class(self, true)


    end


    class ZMMultiLineStringImpl  # :nodoc:


      include ZMGeometryMethods
      include ZMGeometryCollectionMethods
      include ZMMultiLineStringMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiLineString).include_in_class(self, true)


    end


    class ZMMultiPolygonImpl  # :nodoc:


      include ZMGeometryMethods
      include ZMGeometryCollectionMethods
      include ZMMultiPolygonMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiPolygon).include_in_class(self, true)


    end


    class ZMGeometryImpl  # :nodoc:


      include ZMGeometryMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Geometry).include_in_class(self, true)


    end


  end

end
