# -----------------------------------------------------------------------------
#
# Well-known representation for RGeo
#
# -----------------------------------------------------------------------------
# Copyright 2010-2012 Daniel Azuma
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


  # This module contains implementations of the OpenGIS well-known
  # representations: the WKT (well-known text representation) and the
  # WKB (well-known binary representation), as defined in the Simple
  # Features Specification, version 1.1. Facilities are provided to
  # serialize any geometry into one of these formats, and to parse a
  # serialized string back into a geometry. Support is also provided for
  # the common extensions to these formats-- notably, the EWKT and EWKB
  # formats used by PostGIS.
  #
  # To serialize a geometry into WKT (well-known text) format, use
  # the WKRep::WKTGenerator class.
  #
  # To serialize a geometry into WKB (well-known binary) format, use
  # the WKRep::WKBGenerator class.
  #
  # To parse a string in WKT (well-known text) format back into a
  # geometry object, use the WKRep::WKTParser class.
  #
  # To parse a byte string in WKB (well-known binary) format back into a
  # geometry object, use the WKRep::WKBParser class.

  module WKRep
  end


end


# Implementation files
require 'rgeo/wkrep/wkt_parser'
require 'rgeo/wkrep/wkt_generator'
require 'rgeo/wkrep/wkb_parser'
require 'rgeo/wkrep/wkb_generator'
