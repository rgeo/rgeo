# -----------------------------------------------------------------------------
#
# Basic methods used by geometry objects
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

  module ImplHelper  # :nodoc:


    module BasicGeometryMethods  # :nodoc:

      include Feature::Instance


      def inspect  # :nodoc:
        "#<#{self.class}:0x#{object_id.to_s(16)} #{as_text.inspect}>"
      end

      def to_s  # :nodoc:
        as_text
      end


      def _validate_geometry  # :nodoc:
      end


      def _set_factory(factory_)  # :nodoc:
        @factory = factory_
      end


      def factory
        @factory
      end


      def as_text
        @factory._generate_wkt(self)
      end


      def as_binary
        @factory._generate_wkb(self)
      end


      def _copy_state_from(obj_)  # :nodoc:
        @factory = obj_.factory
      end


      def marshal_dump  # :nodoc:
        [@factory, @factory._marshal_wkb_generator.generate(self)]
      end

      def marshal_load(data_)  # :nodoc:
        _copy_state_from(data_[0]._marshal_wkb_parser.parse(data_[1]))
      end


      def encode_with(coder_)  # :nodoc:
        coder_['factory'] = @factory
        coder_['wkt'] = @factory._psych_wkt_generator.generate(self)
      end

      def init_with(coder_)  # :nodoc:
        _copy_state_from(coder_['factory']._psych_wkt_parser.parse(coder_['wkt']))
      end


    end


  end

end
