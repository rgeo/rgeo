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
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR # CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
# -----------------------------------------------------------------------------
;


module RGeo

  module Geos


    module CAPIGeometryMethods  # :nodoc:


      include Feature::Instance


      def inspect
        "#<#{self.class}:0x#{object_id.to_s(16)} #{as_text.inspect}>"
      end


      # Marshal support

      def marshal_dump  # :nodoc:
        factory_ = self.factory
        [factory_, factory_._write_for_marshal(self)]
      end

      def marshal_load(data_)  # :nodoc:
        obj_ = data_[0]._read_for_marshal(data_[1])
        _steal(obj_)
      end


      # Psych support

      def encode_with(coder_)  # :nodoc:
        factory_ = self.factory
        coder_['factory'] = factory_
        str_ = factory_._write_for_psych(self)
        str_ = str_.encode('US-ASCII') if str_.respond_to?(:encode)
        coder_['wkt'] = str_
      end

      def init_with(coder_)  # :nodoc:
        obj_ = coder_['factory']._read_for_psych(coder_['wkt'])
        _steal(obj_)
      end


      def as_text
        str_ = _as_text
        str_.force_encoding('US-ASCII') if str_.respond_to?(:force_encoding)
        str_
      end
      alias_method :to_s, :as_text


    end


    module CAPIGeometryCollectionMethods  # :nodoc:

      include ::Enumerable

    end


    class CAPIGeometryImpl  # :nodoc:


      include CAPIGeometryMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Geometry).include_in_class(self, true)


    end


    class CAPIPointImpl  # :nodoc:


      include CAPIGeometryMethods
      include CAPIPointMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Point).include_in_class(self, true)


    end


    class CAPILineStringImpl  # :nodoc:


      include CAPIGeometryMethods
      include CAPILineStringMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::LineString).include_in_class(self, true)


    end


    class CAPILinearRingImpl  # :nodoc:


      include CAPIGeometryMethods
      include CAPILineStringMethods
      include CAPILinearRingMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::LinearRing).include_in_class(self, true)


    end


    class CAPILineImpl  # :nodoc:


      include CAPIGeometryMethods
      include CAPILineStringMethods
      include CAPILineMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Line).include_in_class(self, true)


    end


    class CAPIPolygonImpl  # :nodoc:


      include CAPIGeometryMethods
      include CAPIPolygonMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::Polygon).include_in_class(self, true)


    end


    class CAPIGeometryCollectionImpl  # :nodoc:


      include CAPIGeometryMethods
      include CAPIGeometryCollectionMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::GeometryCollection).include_in_class(self, true)


    end


    class CAPIMultiPointImpl  # :nodoc:


      include CAPIGeometryMethods
      include CAPIGeometryCollectionMethods
      include CAPIMultiPointMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiPoint).include_in_class(self, true)


    end


    class CAPIMultiLineStringImpl  # :nodoc:


      include CAPIGeometryMethods
      include CAPIGeometryCollectionMethods
      include CAPIMultiLineStringMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiLineString).include_in_class(self, true)


    end


    class CAPIMultiPolygonImpl  # :nodoc:


      include CAPIGeometryMethods
      include CAPIGeometryCollectionMethods
      include CAPIMultiPolygonMethods

      Feature::MixinCollection::GLOBAL.for_type(Feature::MultiPolygon).include_in_class(self, true)


    end


  end

end
