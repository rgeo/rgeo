# -----------------------------------------------------------------------------
#
# MultiCurve feature interface
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

  module Feature


    # == SFS 1.1 Description
    #
    # A MultiCurve is a 1-dimensional GeometryCollection whose elements are
    # Curves.
    #
    # MultiCurve is a non-instantiable class in this specification; it
    # defines a set of methods for its subclasses and is included for
    # reasons of extensibility.
    #
    # A MultiCurve is simple if and only if all of its elements are simple
    # and the only intersections between any two elements occur at Points
    # that are on the boundaries of both elements.
    #
    # The boundary of a MultiCurve is obtained by applying the "mod 2"
    # union rule: A Point is in the boundary of a MultiCurve if it is in
    # the boundaries of an odd number of elements of the MultiCurve.
    #
    # A MultiCurve is closed if all of its elements are closed. The
    # boundary of a closed MultiCurve is always empty.
    #
    # A MultiCurve is defined as topologically closed.
    #
    # == Notes
    #
    # MultiCurve is defined as a module and is provided primarily
    # for the sake of documentation. Implementations need not necessarily
    # include this module itself. Therefore, you should not depend on the
    # kind_of? method to check type. Instead, use the provided check_type
    # class method (or === operator) defined in the Type module.

    module MultiCurve

      include GeometryCollection
      extend Type


      # === SFS 1.1 Description
      #
      # The Length of this MultiCurve which is equal to the sum of the
      # lengths of the element Curves.
      #
      # === Notes
      #
      # Returns a floating-point scalar value.

      def length
        raise Error::UnsupportedOperation, "Method MultiCurve#length not defined."
      end


      # === SFS 1.1 Description
      #
      # Returns true if this MultiCurve is closed [StartPoint() = EndPoint()
      # for each Curve in this MultiCurve].
      #
      # === Notes
      #
      # Returns a boolean value. Note that this is different from the SFS
      # specification, which stipulates an integer return value.

      def is_closed?
        raise Error::UnsupportedOperation, "Method MultiCurve#is_closed? not defined."
      end


    end


  end

end
