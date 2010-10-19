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
  
  module Geography
    
    
    # This class implements the various factories for geography features.
    # See methods of the RGeo::Geography module for the API for creating
    # geography factories.
    
    class Factory
      
      include Features::Factory
      
      
      def initialize(namespace_, opts_={})  # :nodoc:
        @namespace = namespace_
        @opts = opts_.dup
        @projector = @namespace.const_get(:Projector).new(self, opts_) rescue nil
      end
      
      
      # Equivalence test.
      
      def eql?(rhs_)
        rhs_.is_a?(self.class) && @namespace == rhs_.instance_variable_get(:@namespace) &&
          @opts == rhs_.instance_variable_get(:@opts)
      end
      alias_method :==, :eql?
      
      
      # Returns true if this factory supports a projection.
      
      def has_projection?
        !@projector.nil?
      end
      
      
      # Returns the factory for the projected coordinate space,
      # or nil if this factory does not support a projection.
      
      def projection_factory
        @projector ? @projector.projection_factory : nil
      end
      
      
      # Projects the given geometry into the projected coordinate space,
      # and returns the projected geometry.
      # Returns nil if this factory does not support a projection.
      # Raises Errors::IllegalGeometry if the given geometry is not of
      # this factory.
      
      def project(geometry_)
        return nil unless @projector
        unless geometry_.factory == self
          raise Errors::IllegalGeometry, 'Wrong geometry type'
        end
        @projector.project(geometry_)
      end
      
      
      # Reverse-projects the given geometry from the projected coordinate
      # space into lat-long space.
      # Raises Errors::IllegalGeometry if the given geometry is not of
      # the projection defined by this factory.
      
      def unproject(geometry_)
        unless @projector && @projector.projection_factory == geometry_.factory
          raise Errors::IllegalGeometry, 'You can unproject only features that are in the projected coordinate space.'
        end
        @projector.unproject(geometry_)
      end
      
      
      # Returns true if this factory supports a projection and the
      # projection wraps its x (easting) direction. For example, a
      # Mercator projection wraps, but a local projection that is valid
      # only for a small area does not wrap.
      
      def projection_wraps?
        @projector ? @projector.wraps? : nil
      end
      
      
      # Returns a ProjectedWindow specifying the limits of the domain of
      # the projection space.
      # Returns nil if this factory does not support a projection.
      
      def projection_limits_window
        @projector ? (@projection_limits_window ||= @projector.limits_window) : nil
      end
      
      
      # See ::RGeo::Features::Factory#parse_wkt
      
      def parse_wkt(str_)
        Common::Helper.parse_wkt(str_, self)
      end
      
      
      # See ::RGeo::Features::Factory#parse_wkb
      
      def parse_wkb(str_)
        Common::Helper.parse_wkb(str_, self)
      end
      
      
      # See ::RGeo::Features::Factory#point
      
      def point(x_, y_)
        @namespace.const_get(:PointImpl).new(self, x_, y_) rescue nil
      end
      
      
      # See ::RGeo::Features::Factory#line_string
      
      def line_string(points_)
        @namespace.const_get(:LineStringImpl).new(self, points_) rescue nil
      end
      
      
      # See ::RGeo::Features::Factory#line
      
      def line(start_, end_)
        @namespace.const_get(:LineImpl).new(self, start_, end_) rescue nil
      end
      
      
      # See ::RGeo::Features::Factory#linear_ring
      
      def linear_ring(points_)
        if points_.size > 1 && points_.first != points_.last
          points_ << points_.first
        end
        @namespace.const_get(:LinearRingImpl).new(self, points_) rescue nil
      end
      
      
      # See ::RGeo::Features::Factory#polygon
      
      def polygon(outer_ring_, inner_rings_=nil)
        inner_rings_ = inner_rings_.to_a unless inner_rings_.kind_of?(::Array)
        @namespace.const_get(:PolygonImpl).new(self, outer_ring_, inner_rings_) rescue nil
      end
      
      
      # See ::RGeo::Features::Factory#collection
      
      def collection(elems_)
        @namespace.const_get(:GeometryCollectionImpl).new(self, elems_) rescue nil
      end
      
      
      # See ::RGeo::Features::Factory#multi_point
      
      def multi_point(elems_)
        @namespace.const_get(:MultiPointImpl).new(self, elems_) rescue nil
      end
      
      
      # See ::RGeo::Features::Factory#multi_line_string
      
      def multi_line_string(elems_)
        @namespace.const_get(:MultiLineStringImpl).new(self, elems_) rescue nil
      end
      
      
      # See ::RGeo::Features::Factory#multi_polygon
      
      def multi_polygon(elems_)
        @namespace.const_get(:MultiPolygonImpl).new(self, elems_) rescue nil
      end
      
      
      # See ::RGeo::Features::Factory#convert
      
      def convert(original_, force_new_=false)
        if self == original_.factory
          force_new_ ? original_.dup : original_
        else
          case original_
          when Features::Point
            @namespace.const_get(:PointImpl).new(self, original_.x, original_.y) rescue nil
          when Features::Line
            @namespace.const_get(:LineImpl).new(self, original_.start_point, original_.end_point) rescue nil
          when Features::LinearRing
            @namespace.const_get(:LinearRingImpl).new(self, original_.points) rescue nil
          when Features::LineString
            @namespace.const_get(:LineStringImpl).new(self, original_.points) rescue nil
          when Features::Polygon
            @namespace.const_get(:PolygonImpl).new(self, original_.exterior_ring, original_.interior_rings) rescue nil
          when Features::MultiPoint
            @namespace.const_get(:MultiPointImpl).new(self, original_.to_a) rescue nil
          when Features::MultiLineString
            @namespace.const_get(:MultiLineStringImpl).new(self, original_.to_a) rescue nil
          when Features::MultiPolygon
            @namespace.const_get(:MultiPolygonImpl).new(self, original_.to_a) rescue nil
          when Features::GeometryCollection
            @namespace.const_get(:GeometryCollectionImpl).new(self, original_.to_a) rescue nil
          else
            nil
          end
        end
      end
      
      
    end
    
  end
  
end
