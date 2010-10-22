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
    
    
    # This the GEOS implementation of ::RGeo::Features::Factory.
    
    class Factory
      
      include Features::Factory
      
      
      class << self
        
        
        # Create a new factory. Returns nil if the GEOS implementation is
        # not supported.
        # 
        # Options include:
        # 
        # <tt>:lenient_multi_polygon_assertions</tt>::
        #   If set to true, assertion checking on MultiPolygon is disabled.
        #   This may speed up creation of MultiPolygon objects, at the
        #   expense of not doing the proper checking for OGC MultiPolygon
        #   compliance. Default is false.
        # <tt>:buffer_resolution</tt>::
        #   The resolution of buffers around geometries created by this
        #   factory. This controls the number of line segments used to
        #   approximate curves. The default is 1, which causes, for
        #   example, the buffer around a point to be approximated by a
        #   4-sided polygon. A resolution of 2 would cause that buffer
        #   to be approximated by an 8-sided polygon. The exact behavior
        #   for different kinds of buffers is internal to GEOS, and is not
        #   well-specified as far as I can tell.
        # <tt>:srid</tt>::
        #   Set the SRID returned by geometries created by this factory.
        #   Default is 0.
        
        def create(opts_={})
          return nil unless respond_to?(:_create)
          flags_ = 0
          flags_ |= 1 if opts_[:lenient_multi_polygon_assertions]
          buffer_resolution_ = opts_[:buffer_resolution].to_i
          buffer_resolution_ = 1 if buffer_resolution_ < 1
          _create(flags_, opts_[:srid].to_i, buffer_resolution_)
        end
        alias_method :new, :create
        
        
      end
      
      
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
      
      def lenient_multi_polygons?
        _flags & 0x1 != 0
      end
      
      
      # Equivalence test.
      
      def eql?(rhs_)
        rhs_.is_a?(Factory) && rhs_.srid == _srid && rhs_._buffer_resolution == _buffer_resolution && rhs_._flags == _flags
      end
      alias_method :==, :eql?
      
      
      # See ::RGeo::Features::Factory#parse_wkt
      
      def parse_wkt(str_)
        _parse_wkt_impl(str_)
      end
      
      
      # See ::RGeo::Features::Factory#parse_wkb
      
      def parse_wkb(str_)
        _parse_wkb_impl(str_)
      end
      
      
      # See ::RGeo::Features::Factory#point
      
      def point(x_, y_)
        PointImpl.create(self, x_, y_) rescue nil
      end
      
      
      # See ::RGeo::Features::Factory#line_string
      
      def line_string(points_)
        points_ = points_.to_a unless points_.kind_of?(::Array)
        LineStringImpl.create(self, points_) rescue nil
      end
      
      
      # See ::RGeo::Features::Factory#line
      
      def line(start_, end_)
        LineImpl.create(self, start_, end_) rescue nil
      end
      
      
      # See ::RGeo::Features::Factory#linear_ring
      
      def linear_ring(points_)
        points_ = points_.to_a unless points_.kind_of?(::Array)
        if points_.size > 1 && points_.first != points_.last
          points_ << points_.first
        end
        LinearRingImpl.create(self, points_) rescue nil
      end
      
      
      # See ::RGeo::Features::Factory#polygon
      
      def polygon(outer_ring_, inner_rings_=nil)
        inner_rings_ = inner_rings_.to_a unless inner_rings_.kind_of?(::Array)
        PolygonImpl.create(self, outer_ring_, inner_rings_) rescue nil
      end
      
      
      # See ::RGeo::Features::Factory#collection
      
      def collection(elems_)
        elems_ = elems_.to_a unless elems_.kind_of?(::Array)
        GeometryCollectionImpl.create(self, elems_) rescue nil
      end
      
      
      # See ::RGeo::Features::Factory#multi_point
      
      def multi_point(elems_)
        elems_ = elems_.to_a unless elems_.kind_of?(::Array)
        MultiPointImpl.create(self, elems_) rescue nil
      end
      
      
      # See ::RGeo::Features::Factory#multi_line_string
      
      def multi_line_string(elems_)
        elems_ = elems_.to_a unless elems_.kind_of?(::Array)
        MultiLineStringImpl.create(self, elems_) rescue nil
      end
      
      
      # See ::RGeo::Features::Factory#multi_polygon
      
      def multi_polygon(elems_)
        elems_ = elems_.to_a unless elems_.kind_of?(::Array)
        MultiPolygonImpl.create(self, elems_) rescue nil
      end
      
      
      # See ::RGeo::Features::Factory#coerce
      
      def coerce(original_, force_new_=false)
        return nil unless Geos.supported?
        case original_
        when GeometryImpl
          if original_.factory != self
            result_ = original_.dup
            result_.instance_variable_set(:@_factory, self)
            result_
          elsif force_new_
            original_.dup
          else
            original_
          end
        when Features::Point
          if original_.respond_to?(:z)
            PointImpl.create(self, original_.x, original_.y, original_.z)
          else
            PointImpl.create(self, original_.x, original_.y)
          end
        when Features::Line
          LineImpl.create(self, coerce(original_.start_point), coerce(original_.end_point))
        when Features::LinearRing
          LinearRingImpl.create(self, original_.points.map{ |g_| coerce(g_) })
        when Features::LineString
          LineStringImpl.create(self, original_.points.map{ |g_| coerce(g_) })
        when Features::Polygon
          PolygonImpl.create(self, coerce(original_.exterior_ring), original_.interior_rings.map{ |g_| coerce(g_) })
        when Features::MultiPoint
          MultiPointImpl.create(self, original_.to_a.map{ |g_| coerce(g_) })
        when Features::MultiLineString
          MultiLineStringImpl.create(self, original_.to_a.map{ |g_| coerce(g_) })
        when Features::MultiPolygon
          MultiPolygonImpl.create(self, original_.to_a.map{ |g_| coerce(g_) })
        when Features::GeometryCollection
          GeometryCollectionImpl.create(self, original_.to_a.map{ |g_| coerce(g_) })
        else
          nil
        end
      end
      
      
      # A GEOS extension that creates a 3-D point with a Z coordinate.
      
      def point3d(x_, y_, z_)
        PointImpl.create3d(self, x_, y_, z_) rescue nil
      end
      
      
    end
    
    
  end
  
end
