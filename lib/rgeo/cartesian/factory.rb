# -----------------------------------------------------------------------------
# 
# Geographic data factory implementation
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
  
  module Cartesian
    
    
    # This class implements the factory for the simple cartesian
    # implementation.
    
    class Factory
      
      include Feature::Factory::Instance
      
      
      # Create a new simple cartesian factory.
      # 
      # See ::RGeo::Cartesian::simple_factory for a list of supported options.
      
      def initialize(opts_={})
        @srid = opts_[:srid].to_i
        @support_z = opts_[:support_z_coordinate] ? true : false
        @support_m = opts_[:support_m_coordinate] ? true : false
        @proj4 = opts_[:proj4]
        if CoordSys::Proj4.supported?
          if @proj4.kind_of?(::String) || @proj4.kind_of?(::Hash)
            @proj4 = CoordSys::Proj4.create(@proj4)
          end
        else
          @proj4 = nil
        end
      end
      
      
      # Equivalence test.
      
      def eql?(rhs_)
        rhs_.is_a?(self.class) && @srid == rhs_.srid
      end
      alias_method :==, :eql?
      
      
      # Returns the SRID.
      
      def srid
        @srid
      end
      
      
      # See ::RGeo::Feature::Factory#has_capability?
      
      def has_capability?(name_)
        case name_
        when :z_coordinate
          @support_z
        when :m_coordinate
          @support_m
        when :proj4
          !@proj4.nil?
        else
          nil
        end
      end
      
      
      # See ::RGeo::Feature::Factory#parse_wkt
      
      def parse_wkt(str_)
        WKRep::WKTParser.new(:default_factory => self).parse(str_)
      end
      
      
      # See ::RGeo::Feature::Factory#parse_wkb
      
      def parse_wkb(str_)
        WKRep::WKBParser.new(:default_factory => self).parse(str_)
      end
      
      
      # See ::RGeo::Feature::Factory#point
      
      def point(x_, y_, *extra_)
        PointImpl.new(self, x_, y_, *extra_) rescue nil
      end
      
      
      # See ::RGeo::Feature::Factory#line_string
      
      def line_string(points_)
        LineStringImpl.new(self, points_) rescue nil
      end
      
      
      # See ::RGeo::Feature::Factory#line
      
      def line(start_, end_)
        LineImpl.new(self, start_, end_) rescue nil
      end
      
      
      # See ::RGeo::Feature::Factory#linear_ring
      
      def linear_ring(points_)
        LinearRingImpl.new(self, points_) rescue nil
      end
      
      
      # See ::RGeo::Feature::Factory#polygon
      
      def polygon(outer_ring_, inner_rings_=nil)
        PolygonImpl.new(self, outer_ring_, inner_rings_) rescue nil
      end
      
      
      # See ::RGeo::Feature::Factory#collection
      
      def collection(elems_)
        GeometryCollectionImpl.new(self, elems_) rescue nil
      end
      
      
      # See ::RGeo::Feature::Factory#multi_point
      
      def multi_point(elems_)
        MultiPointImpl.new(self, elems_) rescue nil
      end
      
      
      # See ::RGeo::Feature::Factory#multi_line_string
      
      def multi_line_string(elems_)
        MultiLineStringImpl.new(self, elems_) rescue nil
      end
      
      
      # See ::RGeo::Feature::Factory#multi_polygon
      
      def multi_polygon(elems_)
        MultiPolygonImpl.new(self, elems_) rescue nil
      end
      
      
      # See ::RGeo::Feature::Factory#proj4
      
      def proj4
        @proj4
      end
      
      
    end
    
    
  end
  
end
