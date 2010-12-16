# -----------------------------------------------------------------------------
# 
# OGC CS factory for RGeo
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
    
    
    # This module contains an implementation of the CS (coordinate
    # systems) package of the OGC Coordinate Transform spec. It contains
    # classes for representing ellipsoids, datums, coordinate systems,
    # and other related concepts, as well as a parser for the WKT format
    # for specifying coordinate systems.
    # 
    # Generally, the easiest way to create coordinate system objects is
    # to use RGeo::CoordSys::CS.create_from_wkt, which parses the WKT
    # format. This and other methods of the FactoryMethods module are all
    # available as convenient module functions on the CS module.
    # 
    # Almost the entire spec is implemented here. Currently missing are:
    # 
    # * XML format is not implemented. We're assuming that WKT is the
    #   preferred format.
    # * The PT and CT packages are not implemented.
    # * FittedCoordinateSystem is not implemented.
    
    module CS
      
      
      module FactoryMethods
        
        def create_compound_coordinate_system(name_, head_, tail_)
          CompoundCoordinateSystem.create(name_, head_, tail_)
        end
        
        def create_ellipsoid(name_, semi_major_axis_, semi_minor_axis_, linear_unit_)
          Ellipsoid.create_ellipsoid(name_, semi_major_axis_, semi_minor_axis_, linear_unit_)
        end
        
        def create_flattened_sphere(name_, semi_major_axis_, inverse_flattening_, linear_unit_)
          Ellipsoid.create_flattened_sphere(name_, semi_major_axis_, inverse_flattening_, linear_unit_)
        end
        
        def create_from_wkt(str_)
          WKTParser.new(str_).parse
        end
        
        def create_geographic_coordinate_system(name_, angular_unit_, horizontal_datum_, prime_meridian_, axis0_, axis1_)
          GeographicCoordinateSystem.create(name_, angular_unit_, horizontal_datum_, prime_meridian_, axis0_, axis1_)
        end
        
        def create_horizontal_datum(name_, horizontal_datum_type_, ellipsoid_, to_wgs84_)
          HorizontalDatum.create(name_, horizontal_datum_type_, ellipsoid_, to_wgs84_)
        end
        
        def create_local_coordinate_system(name_, datum_, unit_, axes_)
          LocalCoordinateSystem.create(name_, datum_, unit_, axes_)
        end
        
        def create_local_datum(name_, local_datum_type_)
          LocalDatum.create(name, local_datum_type_)
        end
        
        def create_prime_meridian(name_, angular_unit_, longitude_)
          PrimeMeridian.create(name, angular_unit_, longitude_)
        end
        
        def create_projected_coordinate_system(name_, gcs_, projection_, linear_unit_, axis0_, axis1_)
          ProjectedCoordinateSystem.create(name_, gcs_, projection_, linear_unit_, axis0_, axis1_)
        end
        
        def create_projection(name_, wkt_projection_class_, parameters_)
          Projection.create(name_, wkt_projection_class_, parameters_)
        end
        
        def create_vertical_coordinate_system(name_, vertical_datum_, vertical_unit_, axis_)
          VerticalCoordinateSystem.create(name_, vertical_datum_, vertical_unit_, axis_)
        end
        
        def create_vertical_datum(name_, vertical_datum_type_)
          VerticalDatum.create(name_, vertical_datum_type_)
        end
        
      end
      
      
      class CoordinateSystemFactory
        
        include FactoryMethods
        
      end
      
      
      class << self
        
        include FactoryMethods
        
      end
      
      
    end
    
  end
  
end
