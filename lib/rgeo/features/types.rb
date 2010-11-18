# -----------------------------------------------------------------------------
# 
# Feature type management and casting
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
  
  module Features
    
    
    # These methods are available as module methods (not instance methods)
    # of the various feature types.
    # For example, you may determine whether a feature object is a
    # point by calling:
    # 
    #   ::RGeo::Features::Point.check_type(object)
    # 
    # A corresponding === operator is provided so you can use the type
    # modules in a case-when clause.
    # 
    # You may also use the presence of this module to determine whether
    # a particular object is a feature type:
    # 
    #   object.kind_of?(::RGeo::Features::Type)
    
    module Type
      
      
      # All geometry implementations MUST include this submodule.
      # This serves as a marker that may be used to test an object for
      # feature-ness.
      
      module Instance
      end
      
      
      # Returns true if the given object is this type or a subtype
      # thereof, or if it is a feature object whose geometry_type is
      # this type or a subtype thereof.
      # 
      # Note that feature objects need not actually include this module.
      
      def check_type(rhs_)
        rhs_ = rhs_.geometry_type if rhs_.kind_of?(Instance)
        rhs_.kind_of?(Type) && (rhs_ == self || rhs_.include?(self))
      end
      alias_method :===, :check_type
      
      
      # Returns true if this type is the same type or a subtype of the
      # given type.
      
      def subtype_of?(type_)
        self == type_ || self.include?(type_)
      end
      
      
      # Returns the OpenGIS type name of this type.
      
      def type_name
        self.name.sub('RGeo::Features::', '')
      end
      
      
    end
    
    
    class << self
      
      
      # Cast the given object according to the given parameters.
      # 
      # You may optionally pass a factory, a feature type, the value
      # <tt>:force_new</tt>, and the value <tt>:keep_subtype</tt> as the
      # parameters. You may also pass the parameters as a hash, with the
      # keys <tt>:factory</tt>, <tt>:type</tt>, <tt>:force_new</tt> and
      # <tt>:keep_subtype</tt>.
      # 
      # The given object will be casted into the given factory and
      # feature type, if possible.
      # If the cast is not possible to accomplish, nil is returned.
      # If the factory or type is not provided, or is the same as the
      # object's current attribute, that attribute is not modified.
      # 
      # Normally, casting to a particular type always casts strictly to
      # that type, even if the old type is a subtype of the new type.
      # You can cause cast to retain the subtype by passing
      # <tt>:keep_subtype</tt> as one of the parameters. For example,
      # casting a LinearRing to a LineString will normally yield a
      # LineString. However, if you specify <tt>:keep_subtype</tt>, the
      # casted object will remain a LinearRing. You cannot cast to a
      # non-instantiable type (such as Curve) without specifying
      # <tt>:keep_subtype</tt>.
      # 
      # Normally, if neither the factory nor the type are set to be
      # modified, the original object is returned. However, you may cause
      # cast to return a duplicate of the original object by passing
      # <tt>:force_new</tt> as one of the parameters. This effectively
      # forces cast always to return either a new object or nil.
      # 
      # RGeo provides a default casting algorithm. Individual feature
      # implementation factories may override this and customize the
      # casting behavior by defining the override_cast method. See
      # ::RGeo::Features::Factory#override_cast for more details.
      
      def cast(obj_, *params_)
        # Interpret params
        nfactory_ = factory_ = obj_.factory
        ntype_ = type_ = obj_.geometry_type
        force_new_ = nil
        keep_subtype_ = nil
        params_.each do |param_|
          case param_
          when Factory::Instance
            nfactory_ = param_
          when Geometry
            ntype_ = param_
          when :force_new
            force_new_ = param_
          when :keep_subtype
            keep_subtype_ = param_
          when ::Hash
            nfactory_ = param_[:factory] || nfactory_
            ntype_ = param_[:type] || ntype_
            force_new_ = param_[:force_new] if param_.include?(:force_new)
            keep_subtype_ = param_[:keep_subtype] if param_.include?(:keep_subtype)
          end
        end
        
        # Let the factory override
        if nfactory_.respond_to?(:override_cast)
          override_ = nfactory_.override_cast(obj_, ntype_, keep_subtype_, force_new_)
          return override_ unless override_ == false
        end
        
        # Default algorithm
        ntype_ = type_ if keep_subtype_ && type_.include?(ntype_)
        if nfactory_ == factory_ && ntype_ == type_
          force_new_ ? obj_.dup : obj_
        elsif ntype_ == type_
          if type_ == Point
            extra_ = []
            if nfactory_.has_capability?(:z_coordinate)
              extra_ << (factory_.has_capability?(:z_coordinate) ? obj_.z : 0.0)
            end
            if nfactory_.has_capability?(:m_coordinate)
              extra_ << (factory_.has_capability?(:m_coordinate) ? obj_.m : 0.0)
            end
            nfactory_.point(obj_.x, obj_.y, *extra_)
          elsif type_ == Line
            nfactory_.line(obj_.start_point, obj_.end_point)
          elsif type_ == LinearRing
            nfactory_.linear_ring(obj_.points)
          elsif type_ == LineString
            nfactory_.line_string(obj_.points)
          elsif type_ == Polygon
            nfactory_.polygon(obj_.exterior_ring, obj_.interior_rings)
          elsif type_ == MultiPoint
            nfactory_.multi_point(obj_)
          elsif type_ == MultiLineString
            nfactory_.multi_line_string(obj_)
          elsif type_ == MultiPolygon
            nfactory_.multi_polygon(obj_)
          elsif type_ == GeometryCollection
            nfactory_.collection(obj_)
          else
            nil
          end
        else
          if ntype_ == Point && (type_ == MultiPoint || type_ == GeometryCollection) ||
              (ntype_ == Line || ntype_ == LineString || ntype_ == LinearRing) && (type_ == MultiLineString || type_ == GeometryCollection) ||
              ntype_ == Polygon && (type_ == MultiPolygon || type_ == GeometryCollection)
          then
            if obj_.num_geometries == 1
              cast(obj_.geometry_n(0), nfactory_, ntype_, keep_subtype_, force_new_)
            else
              nil
            end
          elsif ntype_ == Point
            nil
          elsif ntype_ == Line
            if type_ == LineString && obj_.num_points == 2
              nfactory_.line(obj_.point_n(0), obj_.point_n(1))
            else
              nil
            end
          elsif ntype_ == LinearRing
            if type_ == LineString
              nfactory_.linear_ring(obj_.points)
            else
              nil
            end
          elsif ntype_ == LineString
            if type_ == Line || type_ == LinearRing
              nfactory_.line_string(obj_.points)
            else
              nil
            end
          elsif ntype_ == MultiPoint
            if type_ == Point
              nfactory_.multi_point([obj_])
            elsif type_ == GeometryCollection
              nfactory_.multi_point(obj_)
            else
              nil
            end
          elsif ntype_ == MultiLineString
            if type_ == Line || type_ == LinearRing || type_ == LineString
              nfactory_.multi_line_string([obj_])
            elsif type_ == GeometryCollection
              nfactory_.multi_line_string(obj_)
            else
              nil
            end
          elsif ntype_ == MultiPolygon
            if type_ == Polygon
              nfactory_.multi_polygon([obj_])
            elsif type_ == GeometryCollection
              nfactory_.multi_polygon(obj_)
            else
              nil
            end
          elsif ntype_ == GeometryCollection
            if type_ == MultiPoint || type_ == MultiLineString || type_ == MultiPolygon
              nfactory_.collection(obj_)
            else
              nfactory_.collection([obj_])
            end
          else
            nil
          end
        end
      end
      
      
    end
  
    
  end
  
end
