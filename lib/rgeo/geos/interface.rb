# -----------------------------------------------------------------------------
# 
# GEOS toplevel interface
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
    
    @supported = nil
    
    class << self
      
      
      # Returns true if GEOS implementation is supported.
      # If this returns false, GEOS features are not available.
      
      def supported?
        @supported.nil? ? (@supported = Factory.respond_to?(:_create)) : @supported
      end
      
      
      # Returns true if the given feature is a GEOS feature, or if the given
      # factory is a GEOS factory.
      
      def is_geos?(object_)
        supported? && (Factory === object_ || GeometryImpl === object_ || ZMFactory === object_ || ZMGeometryImpl === object_)
      end
      
      
      # Returns a factory for the GEOS implementation.
      # Returns nil if the GEOS implementation is not supported.
      # 
      # Note that GEOS does not natively support 4-dimensional data
      # (i.e. both z and m values). However, RGeo's GEOS wrapper does
      # provide a 4-dimensional factory that utilizes an extra native
      # GEOS object to handle the extra coordinate. Hence, a factory
      # configured with both Z and M support will work, but will be
      # slower than a 2-dimensional or 3-dimensional factory.
      # 
      # Options include:
      # 
      # [<tt>:lenient_multi_polygon_assertions</tt>]
      #   If set to true, assertion checking on MultiPolygon is disabled.
      #   This may speed up creation of MultiPolygon objects, at the
      #   expense of not doing the proper checking for OGC MultiPolygon
      #   compliance. See RGeo::Feature::MultiPolygon for details on
      #   the MultiPolygon assertions. Default is false.
      # [<tt>:buffer_resolution</tt>]
      #   The resolution of buffers around geometries created by this
      #   factory. This controls the number of line segments used to
      #   approximate curves. The default is 1, which causes, for
      #   example, the buffer around a point to be approximated by a
      #   4-sided polygon. A resolution of 2 would cause that buffer
      #   to be approximated by an 8-sided polygon. The exact behavior
      #   for different kinds of buffers is defined by GEOS.
      # [<tt>:srid</tt>]
      #   Set the SRID returned by geometries created by this factory.
      #   Default is 0.
      # [<tt>:proj4</tt>]
      #   The coordinate system in Proj4 format, either as a
      #   CoordSys::Proj4 object or as a string or hash representing the
      #   proj4 format. Optional.
      # [<tt>:coord_sys</tt>]
      #   The coordinate system in OGC form, either as a subclass of
      #   CoordSys::CS::CoordinateSystem, or as a string in WKT format.
      #   Optional.
      # [<tt>:srs_database</tt>]
      #   Optional. If provided, the value should be an implementation of
      #   CoordSys::SRSDatabase::Interface. If both this and an SRID are
      #   provided, they are used to look up the proj4 and coord_sys
      #   objects from a spatial reference system database.
      # [<tt>:has_z_coordinate</tt>]
      #   Support <tt>z_coordinate</tt>. Default is false.
      # [<tt>:has_m_coordinate</tt>]
      #   Support <tt>m_coordinate</tt>. Default is false.
      # [<tt>:wkt_parser</tt>]
      #   Configure the parser for WKT. You may either pass a hash of
      #   configuration parameters for WKRep::WKTParser.new, or the
      #   special value <tt>:geos</tt>, indicating to use the native
      #   GEOS parser. Default is the empty hash, indicating the default
      #   configuration for WKRep::WKTParser.
      #   Note that the special <tt>:geos</tt> value is not supported for
      #   ZM factories, since GEOS currently can't handle ZM natively.
      # [<tt>:wkb_parser</tt>]
      #   Configure the parser for WKB. You may either pass a hash of
      #   configuration parameters for WKRep::WKBParser.new, or the
      #   special value <tt>:geos</tt>, indicating to use the native
      #   GEOS parser. Default is the empty hash, indicating the default
      #   configuration for WKRep::WKBParser.
      #   Note that the special <tt>:geos</tt> value is not supported for
      #   ZM factories, since GEOS currently can't handle ZM natively.
      # [<tt>:wkt_generator</tt>]
      #   Configure the generator for WKT. You may either pass a hash of
      #   configuration parameters for WKRep::WKTGenerator.new, or the
      #   special value <tt>:geos</tt>, indicating to use the native
      #   GEOS generator. Default is <tt>{:convert_case => :upper}</tt>.
      #   Note that the special <tt>:geos</tt> value is not supported for
      #   ZM factories, since GEOS currently can't handle ZM natively.
      # [<tt>:wkb_generator</tt>]
      #   Configure the generator for WKB. You may either pass a hash of
      #   configuration parameters for WKRep::WKBGenerator.new, or the
      #   special value <tt>:geos</tt>, indicating to use the native
      #   GEOS generator. Default is the empty hash, indicating the
      #   default configuration for WKRep::WKBGenerator.
      #   Note that the special <tt>:geos</tt> value is not supported for
      #   ZM factories, since GEOS currently can't handle ZM natively.
      
      def factory(opts_={})
        if supported?
          if opts_[:has_z_coordinate] && opts_[:has_m_coordinate]
            ZMFactory.new(opts_)
          else
            Factory.create(opts_)
          end
        else
          nil
        end
      end
      
      
      # Returns a Feature::FactoryGenerator that creates Geos-backed
      # factories. The given options are used as the default options.
      # 
      # A common case for this is to provide the <tt>:srs_database</tt>
      # as a default. Then, the factory generator need only be passed
      # an SRID and it will automatically fetch the appropriate Proj4
      # and CoordSys objects.
      
      def factory_generator(defaults_={})
        ::Proc.new{ |c_| factory(defaults_.merge(c_)) }
      end
      
      
    end
    
  end
  
end
