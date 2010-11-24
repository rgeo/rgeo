# -----------------------------------------------------------------------------
# 
# GEOS zm factory implementation
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
    
    
    # A factory for Geos that handles both Z and M.
    
    class ZMFactory
      
      include Features::Factory::Instance
      
      
      class << self
        
        
        # Create a new factory. Returns nil if the GEOS implementation is
        # not supported.
        
        def create(opts_={})
          return nil unless Geos.supported?
          new(opts_)
        end
        
        
      end
      
      
      def initialize(opts_={})
        @zfactory = Factory.create(:support_z_coordinate => true, :lenient_multi_polygon_assertions => opts_[:lenient_multi_polygon_assertions], :buffer_resolution => opts_[:buffer_resolution], :srid => opts_[:srid])
        @mfactory = Factory.create(:support_m_coordinate => true, :lenient_multi_polygon_assertions => opts_[:lenient_multi_polygon_assertions], :buffer_resolution => opts_[:buffer_resolution], :srid => opts_[:srid])
      end
      
      
      # Returns the SRID of geometries created by this factory.
      
      def srid
        @zfactory._srid
      end
      
      
      # Returns the resolution used by buffer calculations on geometries
      # created by this factory
      
      def buffer_resolution
        @zfactory._buffer_resolution
      end
      
      
      # Returns true if this factory is lenient with MultiPolygon assertions
      
      def lenient_multi_polygon_assertions?
        @zfactory.lenient_multi_polygon_assertions?
      end
      
      
      # Returns the z-only factory corresponding to this factory.
      
      def z_factory
        @zfactory
      end
      
      
      # Returns the m-only factory corresponding to this factory.
      
      def m_factory
        @mfactory
      end
      
      
      # Factory equivalence test.
      
      def eql?(rhs_)
        rhs_.is_a?(ZMFactory) && rhs_.z_factory == @zfactory
      end
      alias_method :==, :eql?
      
      
      # See ::RGeo::Features::Factory#has_capability?
      
      def has_capability?(name_)
        case name_
        when :z_coordinate, :m_coordinate
          true
        else
          @zfactory.has_capability?(name_)
        end
      end
      
      
      # See ::RGeo::Features::Factory#parse_wkt
      
      def parse_wkt(str_)
        WKRep::WKTParser.new(:default_factory => self).parse(str_)
      end
      
      
      # See ::RGeo::Features::Factory#parse_wkb
      
      def parse_wkb(str_)
        WKRep::WKBParser.new(:default_factory => self).parse(str_)
      end
      
      
      # See ::RGeo::Features::Factory#point
      
      def point(x_, y_, z_=0, m_=0)
        ZMPointImpl.create(self, @zfactory.point(x_, y_, z_), @mfactory.point(x_, y_, m_))
      end
      
      
      # See ::RGeo::Features::Factory#line_string
      
      def line_string(points_)
        ZMLineStringImpl.create(self, @zfactory.line_string(points_), @mfactory.line_string(points_))
      end
      
      
      # See ::RGeo::Features::Factory#line
      
      def line(start_, end_)
        ZMLineStringImpl.create(self, @zfactory.line(start_, end_), @mfactory.line(start_, end_))
      end
      
      
      # See ::RGeo::Features::Factory#linear_ring
      
      def linear_ring(points_)
        ZMLineStringImpl.create(self, @zfactory.linear_ring(points_), @mfactory.linear_ring(points_))
      end
      
      
      # See ::RGeo::Features::Factory#polygon
      
      def polygon(outer_ring_, inner_rings_=nil)
        ZMPolygonImpl.create(self, @zfactory.polygon(outer_ring_, inner_rings_), @mfactory.polygon(outer_ring_, inner_rings_))
      end
      
      
      # See ::RGeo::Features::Factory#collection
      
      def collection(elems_)
        ZMGeometryCollectionImpl.create(self, @zfactory.collection(elems_), @mfactory.collection(elems_))
      end
      
      
      # See ::RGeo::Features::Factory#multi_point
      
      def multi_point(elems_)
        ZMGeometryCollectionImpl.create(self, @zfactory.multi_point(elems_), @mfactory.multi_point(elems_))
      end
      
      
      # See ::RGeo::Features::Factory#multi_line_string
      
      def multi_line_string(elems_)
        ZMMultiLineStringImpl.create(self, @zfactory.multi_line_string(elems_), @mfactory.multi_line_string(elems_))
      end
      
      
      # See ::RGeo::Features::Factory#multi_polygon
      
      def multi_polygon(elems_)
        ZMMultiPolygonImpl.create(self, @zfactory.multi_polygon(elems_), @mfactory.multi_polygon(elems_))
      end
      
      
      # See ::RGeo::Features::Factory#override_cast
      
      def override_cast(original_, ntype_, flags_)
        return nil unless Geos.supported?
        keep_subtype_ = flags_[:keep_subtype]
        force_new_ = flags_[:force_new]
        type_ = original_.geometry_type
        ntype_ = type_ if keep_subtype_ && type_.include?(ntype_)
        case original_
        when ZMGeometryImpl
          # Optimization if we're just changing factories, but to
          # another ZM factory.
          if original_.factory != self && ntype_ == type_
            zresult_ = original_.z_geometry.dup
            zresult_._set_factory(@zfactory)
            mresult_ = original_.m_geometry.dup
            mresult_._set_factory(@mfactory)
            return original_.class.create(self, zresult_, mresult_)
          end
          # LineString conversion optimization.
          if (original_.factory != self || ntype_ != type_) &&
              type_.subtype_of?(Features::LineString) && ntype_.subtype_of?(Features:LineString)
          then
            klass_ = Factory::IMPL_CLASSES[ntype_]
            zresult_ = klass_._copy_from(@zfactory, original_.z_geometry)
            mresult_ = klass_._copy_from(@mfactory, original_.m_geometry)
            return ZMLineStringImpl.create(self, zresult_, mresult_)
          end
        end
        false
      end
      
      
    end
    
    
  end
  
end
