# -----------------------------------------------------------------------------
# 
# Cartesian toplevel interface
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
    
    
    class BoundingBox
      
      
      def initialize(factory_, opts_={})
        @factory = factory_
        @has_z = factory_.has_capability?(:z_coordinate) ? true : false
        @has_m = factory_.has_capability?(:m_coordinate) ? true : false
        @xmin = @xmax = @ymin = @ymax = @zmin = @zmax = @mmin = @mmax = nil
      end
      
      
      def factory
        @factory
      end
      
      
      def empty?
        @xmin.nil?
      end
      
      
      def has_z
        @has_z
      end
      
      
      def has_m
        @has_m
      end
      
      
      def x_min
        @xmin
      end
      
      
      def x_max
        @xmax
      end
      
      
      def y_min
        @ymin
      end
      
      
      def y_max
        @ymax
      end
      
      
      def z_min
        @zmin
      end
      
      
      def z_max
        @zmax
      end
      
      
      def m_min
        @mmin
      end
      
      
      def m_max
        @mmax
      end
      
      
      def enclose(geometry_)
        if geometry_.factory == @factory
          _add_geometry(geometry_)
        else
          _add_geometry(Factory.cast(geometry_, @factory))
        end
        self
      end
      
      
      def to_geometry
        if @xmin
          extras_ = []
          extras_ << @zmin if @has_z
          extras_ << @mmin if @has_m
          point_min_ = @factory.point(@xmin, @ymin, *extras_)
          if @xmin == @xmax && @ymin == @ymax
            point_min_
          else
            extras_ = []
            extras_ << @zmax if @has_z
            extras_ << @mmax if @has_m
            point_max_ = @factory.point(@xmax, @ymax, *extras_)
            if @xmin == @xmax || @ymin == @ymax
              @factory.line(point_min_, point_max_)
            else
              @factory.polygon(@factory.linear_ring(point_min_, @factory.point(@xmax, @ymin, *extras_), point_max_, @factory.point(@xmin, @ymax, *extras_), point_min_))
            end
          end
        else
          @factory.collection([])
        end
      end
      
      
      def _add_geometry(geometry_)  # :nodoc:
        case geometry_
        when Features::Point
          _add_point(geometry_)
        when Features::LineString
          geometry_.points.each{ |p_| _add_point(p_) }
        when Features::Polygon
          geometry_.exterior_ring.points.each{ |p_| _add_point(p_) }
        when Features::MultiPoint
          geometry_.each{ |p_| _add_point(p_) }
        when Features::MultiLineString
          geometry_.each{ |line_| line_.points.each{ |p_| _add_point(p_) } }
        when Features::MultiPolygon
          geometry_.each{ |poly_| poly_.exterior_ring.points.each{ |p_| _add_point(p_) } }
        when Features::GeometryCollection
          geometry_.each{ |g_| _add_geometry(g_) }
        end
      end
      
      
      def _add_point(point_)  # :nodoc:
        if @xmin
          x_ = point_.x
          @xmin = x_ if x_ < @xmin
          @xmax = x_ if x_ > @xmax
          y_ = point_.y
          @ymin = y_ if y_ < @ymin
          @ymax = y_ if y_ > @ymax
          if @has_z
            z_ = point_.z
            @zmin = z_ if z_ < @zmin
            @zmax = z_ if z_ > @zmax
          end
          if @has_m
            m_ = point_.m
            @mmin = m_ if m_ < @mmin
            @mmax = m_ if m_ > @mmax
          end
        else
          @xmin = @xmax = point_.x
          @ymin = @ymax = point_.y
          @zmin = @zmax = point_.z if @has_z
          @mmin = @mmax = point_.m if @has_m
        end
      end
      
      
    end
    
    
  end
  
end
