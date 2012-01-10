# -----------------------------------------------------------------------------
#
# Feature factory interface
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


    # A FactoryGenerator is a callable object (usually a Proc) that
    # takes a configuration as a hash and returns a factory. These are
    # often used, e.g., by parsers to determine what factory the parsed
    # geometry should have.
    #
    # See the call method for a list of common configuration parameters.
    # Different generators will support different parameters. There is
    # no mechanism defined to reflect on the parameters understood by a
    # factory generator.
    #
    # Many of the implementations provide a factory method for creating
    # factories. For example, RGeo::Cartesian.preferred_factory can be
    # called to create a factory using the preferred Cartesian
    # implementation. Thus, to get a corresponding factory generator,
    # you can use the <tt>method</tt> method. e.g.
    #
    #  factory_generator = ::RGeo::Cartesian.method(:preferred_factory)
    #
    # FactoryGenerator is defined as a module and is provided
    # primarily for the sake of documentation. Implementations need not
    # necessarily include this module itself. Therefore, you should not
    # depend on the kind_of? method to determine if an object is a
    # factory generator.

    module FactoryGenerator


      # Generate a factory given a configuration as a hash.
      #
      # If the generator does not recognize or does not support a given
      # configuration value, the behavior is usually determined by the
      # <tt>:strict</tt> configuration element. If <tt>strict</tt> is
      # set to true, the generator should fail fast by returning nil or
      # raising an exception. If it is set to false, the generator should
      # attempt to do the best it can, even if it means returning a
      # factory that does not match the requested configuration.
      #
      # Common parameters are as follows. These are intended as a
      # recommendation only. There is no hard requirement for any
      # particular factory generator to support them.
      #
      # [<tt>:strict</tt>]
      #   If true, return nil or raise an exception if any configuration
      #   was not recognized or not supportable. Otherwise, if false,
      #   the generator should attempt to do its best to return some
      #   viable factory, even if it does not strictly match the
      #   requested configuration. Default is usually false.
      # [<tt>:srid</tt>]
      #   The SRID for the factory and objects it creates.
      #   Default is usually 0.
      # [<tt>:proj4</tt>]
      #   The coordinate system in Proj4 format, either as a
      #   CoordSys::Proj4 object or as a string or hash representing the
      #   proj4 format. This is usually an optional parameter; the default
      #   is usually nil.
      # [<tt>:coord_sys</tt>]
      #   The coordinate system in OGC form, either as a subclass of
      #   CoordSys::CS::CoordinateSystem, or as a string in WKT format.
      #   This is usually an optional parameter; the default is usually
      #   nil.
      # [<tt>:srs_database</tt>]
      #   If provided, look up the Proj4 and OGC coordinate systems from
      #   the given database and SRID.
      # [<tt>:has_z_coordinate</tt>]
      #   Support Z coordinates. Default is usually false.
      # [<tt>:has_m_coordinate</tt>]
      #   Support M coordinates. Default is usually false.

      def call(config_={})
        nil
      end


      # Return a new FactoryGenerator that always returns the given
      # factory.

      def self.single(factory_)
        ::Proc.new{ |c_| factory_ }
      end


      # Return a new FactoryGenerator that calls the given delegate, but
      # modifies the configuration passed to it. You can provide defaults
      # for configuration values not explicitly specified, and you can
      # force certain values to override the given configuration.

      def self.decorate(delegate_, default_config_={}, force_config_={})
        ::Proc.new{ |c_| delegate_.call(default_config_.merge(c_).merge(force_config_)) }
      end


    end


  end

end
