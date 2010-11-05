# -----------------------------------------------------------------------------
# 
# Well-known text parser for RGeo
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


require 'strscan'


module RGeo
  
  module WKRep
    
    
    class WKTParser
      
      
      def initialize(factory_, opts_={}, &block_)
        @factory = factory_
        @factory_factory = block_
        @support_ewkt = opts_[:support_ewkt]
        @support_wkt12 = opts_[:support_wkt12]
        @support_higher_dimensions = opts_[:support_higher_dimensions] || @support_ewkt || @support_wkt12
        @ignore_extra_tokens = opts_[:ignore_extra_tokens]
      end
      
      
      def parse(str_)
        @cur_factory = @factory
        str_ = str_.downcase
        if @support_ewkt && str_ =~ /^srid=(\d+);/
          str_ = $'
          if @factory_factory
            @cur_factory = @factory_factory.call($1.to_i)
          end
        end
        @cur_factory_support_z = @cur_factory.has_capability?(:z_coordinate)
        @cur_factory_support_m = @cur_factory.has_capability?(:m_coordinate)
        _start_scanner(str_)
        obj_ = _parse_type_tag(nil, nil)
        if @cur_token && !@ignore_extra_tokens
          raise Errors::ParseError, "Extra tokens beginning with #{@cur_token.inspect}."
        end
        obj_
      end
      
      
      def _parse_type_tag(expect_z_, expect_m_)  # :nodoc:
        _expect_token_type(::String)
        if @support_ekwt && @cur_token =~ /^(.+)(z?m?)$/
          type_ = $1
          zm_ = $2
        else
          type_ = @cur_token
          zm_ = ''
        end
        _next_token
        if zm_.length == 0 && @support_wkt12 && @cur_token.kind_of?(::String) && @cur_token =~ /^z?m?$/
          zm_ = @cur_token
          _next_token
        end
        if zm_.length > 0 || !@support_higher_dimensions
          nexpect_z_ = zm_[0,1] == 'z'
          if !expect_z_.nil? && nexpect_z_ != expect_z_
            raise Errors::ParseError, "Surrounding collection has Z but contained geometry doesn't."
          end
          expect_z_ = nexpect_z_
          nexpect_m_ = zm_[-1,1] == 'm'
          if !expect_m_.nil? && nexpect_m_ != expect_m_
            raise Errors::ParseError, "Surrounding collection has M but contained geometry doesn't."
          end
          expect_m_ = nexpect_m_
        end
        if expect_z_ && !@cur_factory_support_z
          raise Errors::ParseError, "Type tag declares #{zm_.inspect} but factory doesn't support Z."
        end
        if expect_m_ && !@cur_factory_support_m
          raise Errors::ParseError, "Type tag declares #{zm_.inspect} but factory doesn't support M."
        end
        case type_
        when 'point'
          _parse_point(expect_z_, expect_m_, true)
        when 'linestring'
          _parse_line_string(expect_z_, expect_m_)
        when 'polygon'
          _parse_polygon(expect_z_, expect_m_)
        when 'geometrycollection'
          _parse_geometry_collection(expect_z_, expect_m_)
        when 'multipoint'
          _parse_multi_point(expect_z_, expect_m_)
        when 'multilinestring'
          _parse_multi_line_string(expect_z_, expect_m_)
        when 'multipolygon'
          _parse_multi_polygon(expect_z_, expect_m_)
        else
          raise Errors::ParseError, "Unknown type tag: #{@cur_token.inspect}."
        end
      end
      
      
      def _parse_coords(expect_z_, expect_m_)  # :nodoc:
        _expect_token_type(::Numeric)
        x_ = @cur_token
        _next_token
        _expect_token_type(::Numeric)
        y_ = @cur_token
        _next_token
        extra_ = []
        if expect_z_.nil?
          while ::Numeric === @cur_token
            extra_ << @cur_token
            _next_token
          end
        else
          if expect_z_
            _expect_token_type(::Numeric)
            extra_ << @cur_token
            _next_token
          end
          if expect_m_
            _expect_token_type(::Numeric)
            extra_ << @cur_token
            _next_token
          end
        end
        @cur_factory.point(x_, y_, *extra_)
      end
      
      
      def _parse_point(expect_z_, expect_m_, convert_empty_=false)  # :nodoc:
        if convert_empty_ && @cur_token == 'empty'
          point_ = @cur_factory.multi_point([])
        else
          _expect_token_type(:begin)
          _next_token
          point_ = _parse_coords(expect_z_, expect_m_)
          _expect_token_type(:end)
        end
        _next_token
        point_
      end
      
      
      def _parse_line_string(expect_z_, expect_m_)  # :nodoc:
        points_ = []
        if @cur_token != 'empty'
          _expect_token_type(:begin)
          _next_token
          loop do
            points_ << _parse_coords(expect_z_, expect_m_)
            break if @cur_token == :end
            _expect_token_type(:comma)
            _next_token
          end
        end
        _next_token
        @cur_factory.line_string(points_)
      end
      
      
      def _parse_polygon(expect_z_, expect_m_)  # :nodoc:
        inner_rings_ = []
        if @cur_token == 'empty'
          outer_ring_ = @cur_factory.linear_ring([])
        else
          _expect_token_type(:begin)
          _next_token
          outer_ring_ = _parse_line_string(expect_z_, expect_m_)
          loop do
            break if @cur_token == :end
            _expect_token_type(:comma)
            _next_token
            inner_rings_ << _parse_line_string(expect_z_, expect_m_)
          end
        end
        _next_token
        @cur_factory.polygon(outer_ring_, inner_rings_)
      end
      
      
      def _parse_geometry_collection(expect_z_, expect_m_)  # :nodoc:
        geometries_ = []
        if @cur_token != 'empty'
          _expect_token_type(:begin)
          _next_token
          loop do
            geometries_ << _parse_type_tag(expect_z_, expect_m_)
            break if @cur_token == :end
            _expect_token_type(:comma)
            _next_token
          end
        end
        _next_token
        @cur_factory.collection(geometries_)
      end
      
      
      def _parse_multi_point(expect_z_, expect_m_)  # :nodoc:
        points_ = []
        if @cur_token != 'empty'
          _expect_token_type(:begin)
          _next_token
          loop do
            points_ << _parse_point(expect_z_, expect_m_)
            break if @cur_token == :end
            _expect_token_type(:comma)
            _next_token
          end
        end
        _next_token
        @cur_factory.multi_point(points_)
      end
      
      
      def _parse_multi_line_string(expect_z_, expect_m_)  # :nodoc:
        line_strings_ = []
        if @cur_token != 'empty'
          _expect_token_type(:begin)
          _next_token
          loop do
            line_strings_ << _parse_line_string(expect_z_, expect_m_)
            break if @cur_token == :end
            _expect_token_type(:comma)
            _next_token
          end
        end
        _next_token
        @cur_factory.multi_line_string(line_strings_)
      end
      
      
      def _parse_multi_polygon(expect_z_, expect_m_)  # :nodoc:
        polygons_ = []
        if @cur_token != 'empty'
          _expect_token_type(:begin)
          _next_token
          loop do
            polygons_ << _parse_polygon(expect_z_, expect_m_)
            break if @cur_token == :end
            _expect_token_type(:comma)
            _next_token
          end
        end
        _next_token
        @cur_factory.multi_polygon(polygons_)
      end
      
      
      def _start_scanner(str_)  # :nodoc:
        @_scanner = ::StringScanner.new(str_)
        _next_token
      end
      
      
      def _expect_token_type(type_)  # :nodoc:
        unless type_ === @cur_token
          raise Errors::ParseError, "#{type_.inspect} expected but #{@cur_token.inspect} found."
        end
      end
      
      
      def _next_token(expect_=nil)  # :nodoc:
        if @_scanner.scan_until(/\(|\)|\[|\]|,|[^\s\(\)\[\],]+/)
          token_ = @_scanner.matched
          case token_
          when /^[-+]?(\d+(\.\d*)?|\.\d+)(e[-+]?\d+)?$/
            @cur_token = token_.to_f
          when /^[a-z]+$/
            @cur_token = token_
          when ','
            @cur_token = :comma
          when '(','['
            @cur_token = :begin
          when ']',')'
            @cur_token = :end
          else
            raise Errors::ParseError, "Bad token: #{token_.inspect}"
          end
        else
          @cur_token = nil
        end
        @cur_token
      end
      
      
    end
    
    
  end
  
end
