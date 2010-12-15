# -----------------------------------------------------------------------------
# 
# GEOS factory implementation
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
  
  module Geos
    
    
    # This the GEOS implementation of ::RGeo::Feature::Factory.
    
    class Factory
      
      
      include Feature::Factory::Instance
      
      
      class << self
        
        
        # Create a new factory. Returns nil if the GEOS implementation is
        # not supported.
        # 
        # See ::RGeo::Geos::factory for a list of supported options.
        
        def create(opts_={})
          return nil unless respond_to?(:_create)
          flags_ = 0
          flags_ |= 1 if opts_[:lenient_multi_polygon_assertions]
          flags_ |= 2 if opts_[:has_z_coordinate]
          flags_ |= 4 if opts_[:has_m_coordinate]
          if flags_ & 6 == 6
            raise Error::UnsupportedOperation, "GEOS cannot support both Z and M coordinates at the same time."
          end
          buffer_resolution_ = opts_[:buffer_resolution].to_i
          buffer_resolution_ = 1 if buffer_resolution_ < 1
          proj4_ = opts_[:proj4]
          if CoordSys::Proj4.supported?
            if proj4_.kind_of?(::String) || proj4_.kind_of?(::Hash)
              proj4_ = CoordSys::Proj4.create(proj4_)
            end
          else
            proj4_ = nil
          end
          coord_sys_ = opts_[:coord_sys]
          if coord_sys_.kind_of?(::String)
            coord_sys_ = CoordSys::CS.create_from_wkt(coord_sys_) rescue nil
          end
          result_ = _create(flags_, opts_[:srid].to_i, buffer_resolution_)
          result_.instance_variable_set(:@proj4, proj4_)
          result_.instance_variable_set(:@coord_sys, coord_sys_)
          result_
        end
        alias_method :new, :create
        
        
      end
      
      
      def inspect  # :nodoc:
        "#<#{self.class}:0x#{object_id.to_s(16)} srid=#{_srid} bufres=#{_buffer_resolution} flags=#{_flags}>"
      end
      
      
      # Factory equivalence test.
      
      def eql?(rhs_)
        rhs_.is_a?(Factory) && rhs_.srid == _srid && rhs_._buffer_resolution == _buffer_resolution && rhs_._flags == _flags
      end
      alias_method :==, :eql?
      
      
      # Returns the SRID of geometries created by this factory.
      
      def srid
        _srid
      end
      
      
      # Returns the resolution used by buffer calculations on geometries
      # created by this factory
      
      def buffer_resolution
        _buffer_resolution
      end
      
      
      # Returns true if this factory is lenient with MultiPolygon assertions
      
      def lenient_multi_polygon_assertions?
        _flags & 0x1 != 0
      end
      
      
      # See ::RGeo::Feature::Factory#property
      
      def property(name_)
        case name_
        when :has_z_coordinate
          _flags & 0x2 != 0
        when :has_m_coordinate
          _flags & 0x4 != 0
        when :is_cartesian
          true
        else
          nil
        end
      end
      
      
      # See ::RGeo::Feature::Factory#parse_wkt
      
      def parse_wkt(str_)
        _parse_wkt_impl(str_)
      end
      
      
      # See ::RGeo::Feature::Factory#parse_wkb
      
      def parse_wkb(str_)
        _parse_wkb_impl(str_)
      end
      
      
      # See ::RGeo::Feature::Factory#point
      
      def point(x_, y_, *extra_)
        if extra_.length > (_flags & 6 == 0 ? 0 : 1)
          nil
        else
          PointImpl.create(self, x_, y_, extra_[0].to_f) rescue nil
        end
      end
      
      
      # See ::RGeo::Feature::Factory#line_string
      
      def line_string(points_)
        points_ = points_.to_a unless points_.kind_of?(::Array)
        LineStringImpl.create(self, points_) rescue nil
      end
      
      
      # See ::RGeo::Feature::Factory#line
      
      def line(start_, end_)
        LineImpl.create(self, start_, end_) rescue nil
      end
      
      
      # See ::RGeo::Feature::Factory#linear_ring
      
      def linear_ring(points_)
        points_ = points_.to_a unless points_.kind_of?(::Array)
        LinearRingImpl.create(self, points_) rescue nil
      end
      
      
      # See ::RGeo::Feature::Factory#polygon
      
      def polygon(outer_ring_, inner_rings_=nil)
        inner_rings_ = inner_rings_.to_a unless inner_rings_.kind_of?(::Array)
        PolygonImpl.create(self, outer_ring_, inner_rings_) rescue nil
      end
      
      
      # See ::RGeo::Feature::Factory#collection
      
      def collection(elems_)
        elems_ = elems_.to_a unless elems_.kind_of?(::Array)
        GeometryCollectionImpl.create(self, elems_) rescue nil
      end
      
      
      # See ::RGeo::Feature::Factory#multi_point
      
      def multi_point(elems_)
        elems_ = elems_.to_a unless elems_.kind_of?(::Array)
        MultiPointImpl.create(self, elems_) rescue nil
      end
      
      
      # See ::RGeo::Feature::Factory#multi_line_string
      
      def multi_line_string(elems_)
        elems_ = elems_.to_a unless elems_.kind_of?(::Array)
        MultiLineStringImpl.create(self, elems_) rescue nil
      end
      
      
      # See ::RGeo::Feature::Factory#multi_polygon
      
      def multi_polygon(elems_)
        elems_ = elems_.to_a unless elems_.kind_of?(::Array)
        MultiPolygonImpl.create(self, elems_) rescue nil
      end
      
      
      # See ::RGeo::Feature::Factory#proj4
      
      def proj4
        @proj4
      end
      
      
      # See ::RGeo::Feature::Factory#coord_sys
      
      def coord_sys
        @coord_sys
      end
      
      
      # See ::RGeo::Feature::Factory#override_cast
      
      def override_cast(original_, ntype_, flags_)
        return nil unless Geos.supported?
        keep_subtype_ = flags_[:keep_subtype]
        force_new_ = flags_[:force_new]
        type_ = original_.geometry_type
        ntype_ = type_ if keep_subtype_ && type_.include?(ntype_)
        case original_
        when GeometryImpl
          # Optimization if we're just changing factories, but the
          # factories are zm-compatible.
          if original_.factory != self && ntype_ == type_ &&
              original_.factory._flags & 0x6 == _flags & 0x6
          then
            result_ = original_.dup
            result_._set_factory(self)
            return result_
          end
          # LineString conversion optimization.
          if (original_.factory != self || ntype_ != type_) &&
              original_.factory._flags & 0x6 == _flags & 0x6 &&
              type_.subtype_of?(Feature::LineString) && ntype_.subtype_of?(Feature::LineString)
          then
            return IMPL_CLASSES[ntype_]._copy_from(self, original_)
          end
        when ZMGeometryImpl
          # Optimization for just removing a coordinate from an otherwise
          # compatible factory
          if _flags & 0x6 == 0x2 && self == original_.factory.z_factory
            return Feature.cast(original_.z_geometry, ntype_, flags_)
          elsif _flags & 0x6 == 0x4 && self == original_.factory.m_factory
            return Feature.cast(original_.m_geometry, ntype_, flags_)
          end
        end
        false
      end
      
      
    end
    
    
  end
  
end
