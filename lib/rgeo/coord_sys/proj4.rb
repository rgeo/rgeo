# -----------------------------------------------------------------------------
# 
# Proj4 wrapper for RGeo
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
  
  module CoordSys
    
    
    # This is a Ruby wrapper around a Proj4 coordinate system.
    # It represents a single geographic coordinate system, which may be
    # a flat projection, a geocentric (3-dimensional) coordinate system,
    # or a geographic (latitude-longitude) coordinate system.
    # 
    # Generally, these are used to define the projection for a
    # Feature::Factory. You can then convert between coordinate systems
    # by casting geometries between such factories using the :project
    # option. You may also use this object directly to perform low-level
    # coordinate transformations.
    
    class Proj4
      
      
      def inspect  # :nodoc:
        "#<#{self.class}:0x#{object_id.to_s(16)} #{_canonical_str.inspect}>"
      end
      
      
      def to_s  # :nodoc:
        _canonical_str
      end
      
      
      def hash  # :nodoc:
        _canonical_str.hash
      end
      
      
      # Returns true if this Proj4 is equivalent to the given Proj4.
      # 
      # Note: this tests for equivalence by comparing only the hash
      # definitions of the Proj4 objects, and returning true if those
      # definitions are equivalent. In some cases, this may still return
      # false even if the actual coordinate systems are identical, since
      # there are sometimes multiple ways to express a given coordinate
      # system.
      
      def eql?(rhs_)
        rhs_.is_a?(Proj4) && rhs_._canonical_hash == canonical_hash
      end
      
      
      # Returns the "canonical" string definition for this coordinate
      # system, as reported by Proj4. This may be slightly different
      # from the definition used to construct this object.
      
      def canonical_str
        _canonical_str
      end
      
      
      # Returns the "canonical" hash definition for this coordinate
      # system, as reported by Proj4. This may be slightly different
      # from the definition used to construct this object.
      
      def canonical_hash
        hash_ = {}
        _canonical_str.strip.split(/\s+/).each do |elem_|
          if elem_ =~ /^\+(\w+)(=(\S+))?$/
            hash_[$1] = $3
          end
        end
        hash_
      end
      
      
      # Returns the string definition originally used to construct this
      # object. Returns nil if this object wasn't created by a string
      # definition; i.e. if it was created using get_geographic.
      
      def original_str
        _original_str
      end
      
      
      # Returns true if this Proj4 object is a geographic (lat-long)
      # coordinate system.
      
      def geographic?
        _geographic?
      end
      
      
      # Returns true if this Proj4 object is a geocentric (3dz)
      # coordinate system.
      
      def geocentric?
        _geocentric?
      end
      
      
      # Get the geographic (unprojected lat-long) coordinate system
      # corresponding to this coordinate system; i.e. the one that uses
      # the same ellipsoid and datum.
      
      def get_geographic
        _get_geographic
      end
      
      
      class << self
        
        
        # Returns true if Proj4 is supported in this installation.
        # If this returns false, the other methods such as create
        # will not work.
        
        def supported?
          respond_to?(:_create)
        end
        
        
        # Create a new Proj4 object, given a definition, which may be
        # either a string or a hash. Returns nil if the given definition
        # is invalid or Proj4 is not supported.
        
        def create(defn_)
          result_ = nil
          if supported?
            if defn_.kind_of?(::Hash)
              defn_ = defn_.map{ |k_, v_| v_ ? "+#{k_}=#{v_}" : "+#{k_}" }.join(' ')
            end
            result_ = _create(defn_)
            result_ = nil unless result_._valid?
          end
          result_
        end
        
        
        # Create a new Proj4 object, given a definition, which may be
        # either a string or a hash. Raises Error::UnsupportedCapability
        # if the given definition is invalid or Proj4 is not supported.
        
        def new(defn_)
          result_ = create(defn_)
          unless result_
            raise Error::UnsupportedCapability, "Proj4 not supported in this installation"
          end
          result_
        end
        
        
        # Low-level coordinate transform method.
        # Transforms the given coordinate (x, y, [z]) from one proj4
        # coordinate system to another. Returns an array with either two
        # or three elements.
        
        def transform_coords(from_proj_, to_proj_, x_, y_, z_=nil)
          _transform_coords(from_proj_, to_proj_, x_, y_, z_)
        end
        
        
        # Low-level geometry transform method.
        # Transforms the given geometry between the given two projections.
        # The resulting geometry is constructed using the to_factory.
        # Any projections associated with the factories themselves are
        # ignored.
        
        def transform(from_proj_, from_geometry_, to_proj_, to_factory_)
          case from_geometry_
          when Feature::Point
            _transform_point(from_proj_, from_geometry_, to_proj_, to_factory_)
          when Feature::Line
            to_factory_.line(from_geometry_.points.map{ |p_| transform(from_proj_, p_, to_proj_, to_factory_) })
          when Feature::LinearRing
            _transform_linear_ring(from_proj_, from_geometry_, to_proj_, to_factory_)
          when Feature::LineString
            to_factory_.line_string(from_geometry_.points.map{ |p_| transform(from_proj_, p_, to_proj_, to_factory_) })
          when Feature::Polygon
            _transform_polygon(from_proj_, from_geometry_, to_proj_, to_factory_)
          when Feature::MultiPoint
            to_factory_.multi_point(from_geometry_.map{ |p_| _transform_point(from_proj_, p_, to_proj_, to_factory_) })
          when Feature::MultiLineString
            to_factory_.multi_line_string(from_geometry_.map{ |g_| transform(from_proj_, g_, to_proj_, to_factory_) })
          when Feature::MultiPolygon
            to_factory_.multi_polygon(from_geometry_.map{ |p_| _transform_polygon(from_proj_, p_, to_proj_, to_factory_) })
          when Feature::GeometryCollection
            to_factory_.collection(from_geometry_.map{ |g_| transform(from_proj_, g_, to_proj_, to_factory_) })
          end
        end
        
        
        def _transform_point(from_proj_, from_point_, to_proj_, to_factory_)  # :nodoc:
          from_factory_ = from_point_.factory
          from_has_z_ = from_factory_.has_capability?(:z_coordinate)
          from_has_m_ = from_factory_.has_capability?(:m_coordinate)
          to_has_z_ = to_factory_.has_capability?(:z_coordinate)
          to_has_m_ = to_factory_.has_capability?(:m_coordinate)
          coords_ = _transform_coords(from_proj_, to_proj_, from_point_.x, from_point_.y,
                                      from_has_z_ ? from_point_.z : nil)
          extras_ = []
          extras_ << coords_[2].to_f if to_has_z_
          extras_ << from_has_m_ ? from_point_.m : 0.0 if to_has_m_?
          to_factory_.point(coords_[0], coords_[1], extras_)
        end
        
        
        def _transform_linear_ring(from_proj_, from_ring_, to_proj_, to_factory_)  # :nodoc:
          to_factory_.linear_ring(from_ring_.points[0..-2].map{ |p_| transform(from_proj_, p_, to_proj_, to_factory_) })
        end
        
        
        def _transform_polygon(from_proj_, from_polygon_, to_proj_, to_factory_)  # :nodoc:
          ext_ = _transform_linear_ring(from_proj_, from_polygon_.exterior_ring, to_proj_, to_factory_)
          int_ = from_polygon_.interior_rings.map{ |r_| _transform_linear_ring(from_proj_, r_, to_proj_, to_factory_) }
          to_factory_.polygon(ext_, int_)
        end
        
        
      end
      
      
    end
    
    
  end
  
end
