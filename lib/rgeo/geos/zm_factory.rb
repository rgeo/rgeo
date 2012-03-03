# -----------------------------------------------------------------------------
#
# GEOS zm factory implementation
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

  module Geos


    # A factory for Geos that handles both Z and M.

    class ZMFactory

      include Feature::Factory::Instance


      class << self


        # Create a new factory. Returns nil if the GEOS implementation is
        # not supported.

        def create(opts_={})
          return nil unless Geos.supported?
          new(opts_)
        end


      end


      def initialize(opts_={})  # :nodoc:
        proj4_ = opts_[:proj4]
        coord_sys_ = opts_[:coord_sys]
        srid_ = opts_[:srid]
        if (!proj4_ || !coord_sys_) && srid_ && (db_ = opts_[:srs_database])
          entry_ = db_.get(srid_.to_i)
          if entry_
            proj4_ ||= entry_.proj4
            coord_sys_ ||= entry_.coord_sys
          end
        end
        srid_ ||= coord_sys_.authority_code if coord_sys_
        config_ = {
          :uses_lenient_multi_polygon_assertions => opts_[:lenient_multi_polygon_assertions] ||
            opts_[:uses_lenient_multi_polygon_assertions],
          :buffer_resolution => opts_[:buffer_resolution], :auto_prepare => opts_[:auto_prepare],
          :wkt_generator => opts_[:wkt_generator], :wkt_parser => opts_[:wkt_parser],
          :wkb_generator => opts_[:wkb_generator], :wkb_parser => opts_[:wkb_parser],
          :srid => srid_.to_i, :proj4 => proj4_, :coord_sys => coord_sys_,
        }
        native_interface_ = opts_[:native_interface] || Geos.preferred_native_interface
        if native_interface_ == :ffi
          @zfactory = FFIFactory.new(config_.merge(:has_z_coordinate => true))
          @mfactory = FFIFactory.new(config_.merge(:has_m_coordinate => true))
        else
          @zfactory = Factory.create(config_.merge(:has_z_coordinate => true))
          @mfactory = Factory.create(config_.merge(:has_m_coordinate => true))
        end

        wkt_generator_ = opts_[:wkt_generator]
        case wkt_generator_
        when ::Hash
          @wkt_generator = WKRep::WKTGenerator.new(wkt_generator_)
        else
          @wkt_generator = WKRep::WKTGenerator.new(:convert_case => :upper)
        end
        wkb_generator_ = opts_[:wkb_generator]
        case wkb_generator_
        when ::Hash
          @wkb_generator = WKRep::WKBGenerator.new(wkb_generator_)
        else
          @wkb_generator = WKRep::WKBGenerator.new
        end
        wkt_parser_ = opts_[:wkt_parser]
        case wkt_parser_
        when ::Hash
          @wkt_parser = WKRep::WKTParser.new(self, wkt_parser_)
        else
          @wkt_parser = WKRep::WKTParser.new(self)
        end
        wkb_parser_ = opts_[:wkb_parser]
        case wkb_parser_
        when ::Hash
          @wkb_parser = WKRep::WKBParser.new(self, wkb_parser_)
        else
          @wkb_parser = WKRep::WKBParser.new(self)
        end
      end


      # Marshal support

      def marshal_dump  # :nodoc:
        hash_ = {
          'srid' => @zfactory.srid,
          'bufr' => @zfactory.buffer_resolution,
          'wktg' => @wkt_generator._properties,
          'wkbg' => @wkb_generator._properties,
          'wktp' => @wkt_parser._properties,
          'wkbp' => @wkb_parser._properties,
          'lmpa' => @zfactory.lenient_multi_polygon_assertions?,
          'apre' => @zfactory.property(:auto_prepare) == :simple,
          'nffi' => @zfactory.is_a?(FFIFactory),
        }
        proj4_ = @zfactory.proj4
        coord_sys_ = @zfactory.coord_sys
        hash_['proj4'] = proj4_.marshal_dump if proj4_
        hash_['cs'] = coord_sys_.to_wkt if coord_sys_
        hash_
      end

      def marshal_load(data_)  # :nodoc:
        if CoordSys::Proj4.supported? && (proj4_data_ = data_['proj4'])
          proj4_ = CoordSys::Proj4.allocate
          proj4_.marshal_load(proj4_data_)
        else
          proj4_ = nil
        end
        if (coord_sys_data_ = data_['cs'])
          coord_sys_ = CoordSys::CS.create_from_wkt(coord_sys_data_)
        else
          coord_sys_ = nil
        end
        initialize(
          :native_interface => (data_['nffi'] ? :ffi : :capi),
          :has_z_coordinate => data_['hasz'],
          :has_m_coordinate => data_['hasm'],
          :srid => data_['srid'],
          :buffer_resolution => data_['bufr'],
          :wkt_generator => ImplHelper::Utils.symbolize_hash(data_['wktg']),
          :wkb_generator => ImplHelper::Utils.symbolize_hash(data_['wkbg']),
          :wkt_parser => ImplHelper::Utils.symbolize_hash(data_['wktp']),
          :wkb_parser => ImplHelper::Utils.symbolize_hash(data_['wkbp']),
          :uses_lenient_multi_polygon_assertions => data_['lmpa'],
          :auto_prepare => (data_['apre'] ? :simple : :disabled),
          :proj4 => proj4_,
          :coord_sys => coord_sys_
        )
      end


      # Psych support

      def encode_with(coder_)  # :nodoc:
        coder_['srid'] = @zfactory.srid
        coder_['buffer_resolution'] = @zfactory.buffer_resolution
        coder_['lenient_multi_polygon_assertions'] = @zfactory.lenient_multi_polygon_assertions?
        coder_['wkt_generator'] = @wkt_generator._properties
        coder_['wkb_generator'] = @wkb_generator._properties
        coder_['wkt_parser'] = @wkt_parser._properties
        coder_['wkb_parser'] = @wkb_parser._properties
        coder_['auto_prepare'] = @zfactory.property(:auto_prepare).to_s
        coder_['native_interface'] = @zfactory.is_a?(FFIFactory) ? 'ffi' : 'capi'
        if @proj4
          str_ = @proj4.original_str || @proj4.canonical_str
          coder_['proj4'] = @proj4.radians? ? {'proj4' => str_, 'radians' => true} : str_
        end
        coder_['coord_sys'] = @coord_sys.to_wkt if @coord_sys
      end

      def init_with(coder_)  # :nodoc:
        if (proj4_data_ = coder_['proj4'])
          if proj4_data_.is_a?(::Hash)
            proj4_ = CoordSys::Proj4.create(proj4_data_['proj4'], :radians => proj4_data_['radians'])
          else
            proj4_ = CoordSys::Proj4.create(proj4_data_.to_s)
          end
        else
          proj4_ = nil
        end
        if (coord_sys_data_ = coder_['cs'])
          coord_sys_ = CoordSys::CS.create_from_wkt(coord_sys_data_.to_s)
        else
          coord_sys_ = nil
        end
        initialize(
          :native_interface => coder_['native_interface'] == 'ffi' ? :ffi : :capi,
          :has_z_coordinate => coder_['has_z_coordinate'],
          :has_m_coordinate => coder_['has_m_coordinate'],
          :srid => coder_['srid'],
          :buffer_resolution => coder_['buffer_resolution'],
          :wkt_generator => ImplHelper::Utils.symbolize_hash(coder_['wkt_generator']),
          :wkb_generator => ImplHelper::Utils.symbolize_hash(coder_['wkb_generator']),
          :wkt_parser => ImplHelper::Utils.symbolize_hash(coder_['wkt_parser']),
          :wkb_parser => ImplHelper::Utils.symbolize_hash(coder_['wkb_parser']),
          :auto_prepare => coder_['auto_prepare'] == 'disabled' ? :disabled : :simple,
          :uses_lenient_multi_polygon_assertions => coder_['lenient_multi_polygon_assertions'],
          :proj4 => proj4_,
          :coord_sys => coord_sys_
        )
      end


      # Returns the SRID of geometries created by this factory.

      def srid
        @zfactory.srid
      end


      # Returns the resolution used by buffer calculations on geometries
      # created by this factory

      def buffer_resolution
        @zfactory.buffer_resolution
      end


      # Returns true if this factory is lenient with MultiPolygon assertions

      def lenient_multi_polygon_assertions?
        @zfactory.lenient_multi_polygon_assertions?
      end


      # Returns the z-only factory corresponding to this factory.

      def z_factory
        @zfactory
      end


      # Returns the m-only factory corresponding to this factory.

      def m_factory
        @mfactory
      end


      # Factory equivalence test.

      def eql?(rhs_)
        rhs_.is_a?(ZMFactory) && rhs_.z_factory == @zfactory
      end
      alias_method :==, :eql?


      # See ::RGeo::Feature::Factory#property

      def property(name_)
        case name_
        when :has_z_coordinate, :has_m_coordinate, :is_cartesian
          true
        else
          nil
        end
      end


      # See ::RGeo::Feature::Factory#parse_wkt

      def parse_wkt(str_)
        @wkt_parser.parse(str_)
      end


      # See ::RGeo::Feature::Factory#parse_wkb

      def parse_wkb(str_)
        @wkb_parser.parse(str_)
      end


      # See ::RGeo::Feature::Factory#point

      def point(x_, y_, z_=0, m_=0)
        ZMPointImpl.create(self, @zfactory.point(x_, y_, z_), @mfactory.point(x_, y_, m_))
      end


      # See ::RGeo::Feature::Factory#line_string

      def line_string(points_)
        ZMLineStringImpl.create(self, @zfactory.line_string(points_), @mfactory.line_string(points_))
      end


      # See ::RGeo::Feature::Factory#line

      def line(start_, end_)
        ZMLineStringImpl.create(self, @zfactory.line(start_, end_), @mfactory.line(start_, end_))
      end


      # See ::RGeo::Feature::Factory#linear_ring

      def linear_ring(points_)
        ZMLineStringImpl.create(self, @zfactory.linear_ring(points_), @mfactory.linear_ring(points_))
      end


      # See ::RGeo::Feature::Factory#polygon

      def polygon(outer_ring_, inner_rings_=nil)
        ZMPolygonImpl.create(self, @zfactory.polygon(outer_ring_, inner_rings_), @mfactory.polygon(outer_ring_, inner_rings_))
      end


      # See ::RGeo::Feature::Factory#collection

      def collection(elems_)
        ZMGeometryCollectionImpl.create(self, @zfactory.collection(elems_), @mfactory.collection(elems_))
      end


      # See ::RGeo::Feature::Factory#multi_point

      def multi_point(elems_)
        ZMGeometryCollectionImpl.create(self, @zfactory.multi_point(elems_), @mfactory.multi_point(elems_))
      end


      # See ::RGeo::Feature::Factory#multi_line_string

      def multi_line_string(elems_)
        ZMMultiLineStringImpl.create(self, @zfactory.multi_line_string(elems_), @mfactory.multi_line_string(elems_))
      end


      # See ::RGeo::Feature::Factory#multi_polygon

      def multi_polygon(elems_)
        ZMMultiPolygonImpl.create(self, @zfactory.multi_polygon(elems_), @mfactory.multi_polygon(elems_))
      end


      # See ::RGeo::Feature::Factory#proj4

      def proj4
        @zfactory.proj4
      end


      # See ::RGeo::Feature::Factory#coord_sys

      def coord_sys
        @zfactory.coord_sys
      end


      # See ::RGeo::Feature::Factory#override_cast

      def override_cast(original_, ntype_, flags_)
        return nil unless Geos.supported?
        keep_subtype_ = flags_[:keep_subtype]
        force_new_ = flags_[:force_new]
        project_ = flags_[:project]
        type_ = original_.geometry_type
        ntype_ = type_ if keep_subtype_ && type_.include?(ntype_)
        case original_
        when ZMGeometryImpl
          # Optimization if we're just changing factories, but to
          # another ZM factory.
          if original_.factory != self && ntype_ == type_ &&
              (!project_ || original_.factory.proj4 == @proj4)
          then
            zresult_ = original_.z_geometry.dup
            zresult_._set_factory(@zfactory)
            mresult_ = original_.m_geometry.dup
            mresult_._set_factory(@mfactory)
            return original_.class.create(self, zresult_, mresult_)
          end
          # LineString conversion optimization.
          if (original_.factory != self || ntype_ != type_) &&
              (!project_ || original_.factory.proj4 == @proj4) &&
              type_.subtype_of?(Feature::LineString) && ntype_.subtype_of?(Feature::LineString)
          then
            klass_ = Factory::IMPL_CLASSES[ntype_]
            zresult_ = klass_._copy_from(@zfactory, original_.z_geometry)
            mresult_ = klass_._copy_from(@mfactory, original_.m_geometry)
            return ZMLineStringImpl.create(self, zresult_, mresult_)
          end
        end
        false
      end


    end


  end

end
