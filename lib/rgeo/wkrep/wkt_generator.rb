# -----------------------------------------------------------------------------
#
# Well-known text generator for RGeo
#
# -----------------------------------------------------------------------------

module RGeo
  module WKRep
    # This class provides the functionality of serializing a geometry as
    # WKT (well-known text) format. You may also customize the serializer
    # to generate PostGIS EWKT extensions to the output, or to follow the
    # Simple Features Specification 1.2 extensions for Z and M.
    #
    # To use this class, create an instance with the desired settings and
    # customizations, and call the generate method.
    #
    # === Configuration options
    #
    # The following options are recognized. These can be passed to the
    # constructor, or set on the object afterwards.
    #
    # [<tt>:tag_format</tt>]
    #   The format for tags. Possible values are <tt>:wkt11</tt>,
    #   indicating SFS 1.1 WKT (i.e. no Z or M markers in the tags) but
    #   with Z and/or M values added in if they are present;
    #   <tt>:wkt11_strict</tt>, indicating SFS 1.1 WKT with Z and M
    #   dropped from the output (since WKT strictly does not support
    #   the Z or M dimensions); <tt>:ewkt</tt>, indicating the PostGIS
    #   EWKT extensions (i.e. "M" appended to tag names if M but not
    #   Z is present); or <tt>:wkt12</tt>, indicating SFS 1.2 WKT
    #   tags that indicate the presence of Z and M in a separate token.
    #   Default is <tt>:wkt11</tt>.
    #   This option can also be specified as <tt>:type_format</tt>.
    # [<tt>:emit_ewkt_srid</tt>]
    #   If true, embed the SRID of the toplevel geometry. Available only
    #   if <tt>:tag_format</tt> is <tt>:ewkt</tt>. Default is false.
    # [<tt>:square_brackets</tt>]
    #   If true, uses square brackets rather than parentheses.
    #   Default is false.
    # [<tt>:convert_case</tt>]
    #   Possible values are <tt>:upper</tt>, which changes all letters
    #   in the output to ALL CAPS; <tt>:lower</tt>, which changes all
    #   letters to lower case; or nil, indicating no case changes from
    #   the default (which is not specified exactly, but is chosen by the
    #   generator to emphasize readability.) Default is nil.

    class WKTGenerator
      # Create and configure a WKT generator. See the WKTGenerator
      # documentation for the options that can be passed.

      def initialize(opts_ = {})
        @tag_format = opts_[:tag_format] || opts_[:type_format] || :wkt11
        @emit_ewkt_srid = @tag_format == :ewkt ?
          (opts_[:emit_ewkt_srid] ? true : false) : nil
        @square_brackets = opts_[:square_brackets] ? true : false
        @convert_case = opts_[:convert_case]
      end

      # Returns the format for type tags. See WKTGenerator for details.
      attr_reader :tag_format
      alias_method :type_format, :tag_format

      # Returns whether SRID is embedded. See WKTGenerator for details.
      def emit_ewkt_srid?
        @emit_ewkt_srid
      end

      # Returns whether square brackets rather than parens are output.
      # See WKTGenerator for details.
      def square_brackets?
        @square_brackets
      end

      # Returns the case for output. See WKTGenerator for details.
      attr_reader :convert_case

      def _properties # :nodoc:
        {
          "tag_format" => @tag_format.to_s,
          "emit_ewkt_srid" => @emit_ewkt_srid,
          "square_brackets" => @square_brackets,
          "convert_case" => @convert_case ? @convert_case.to_s : nil
        }
      end

      # Generate and return the WKT format for the given geometry object,
      # according to the current settings.

      def generate(obj_)
        @begin_bracket = @square_brackets ? "[" : "("
        @end_bracket = @square_brackets ? "]" : ")"
        factory_ = obj_.factory
        if @tag_format == :wkt11_strict
          @cur_support_z = nil
          @cur_support_m = nil
        else
          @cur_support_z = factory_.property(:has_z_coordinate)
          @cur_support_m = factory_.property(:has_m_coordinate)
        end
        str_ = _generate_feature(obj_, true)
        if @convert_case == :upper
          str_.upcase
        elsif @convert_case == :lower
          str_.downcase
        else
          str_
        end
      end

      def _generate_feature(obj_, toplevel_ = false) # :nodoc:
        type_ = obj_.geometry_type
        type_ = Feature::LineString if type_.subtype_of?(Feature::LineString)
        tag_ = type_.type_name
        if @tag_format == :ewkt
          tag_ << "M" if @cur_support_m && !@cur_support_z
          tag_ = "SRID=#{obj_.srid};#{tag_}" if toplevel_ && @emit_ewkt_srid
        elsif @tag_format == :wkt12
          if @cur_support_z
            if @cur_support_m
              tag_ << " ZM"
            else
              tag_ << " Z"
            end
          elsif @cur_support_m
            tag_ << " M"
          end
        end
        if type_ == Feature::Point
          "#{tag_} #{_generate_point(obj_)}"
        elsif type_ == Feature::LineString
          "#{tag_} #{_generate_line_string(obj_)}"
        elsif type_ == Feature::Polygon
          "#{tag_} #{_generate_polygon(obj_)}"
        elsif type_ == Feature::GeometryCollection
          "#{tag_} #{_generate_geometry_collection(obj_)}"
        elsif type_ == Feature::MultiPoint
          "#{tag_} #{_generate_multi_point(obj_)}"
        elsif type_ == Feature::MultiLineString
          "#{tag_} #{_generate_multi_line_string(obj_)}"
        elsif type_ == Feature::MultiPolygon
          "#{tag_} #{_generate_multi_polygon(obj_)}"
        else
          raise Error::ParseError, "Unrecognized geometry type: #{type_}"
        end
      end

      def _generate_coords(obj_) # :nodoc:
        str_ = "#{obj_.x} #{obj_.y}"
        str_ << " #{obj_.z}" if @cur_support_z
        str_ << " #{obj_.m}" if @cur_support_m
        str_
      end

      def _generate_point(obj_) # :nodoc:
        "#{@begin_bracket}#{_generate_coords(obj_)}#{@end_bracket}"
      end

      def _generate_line_string(obj_) # :nodoc:
        if obj_.is_empty?
          "EMPTY"
        else
          "#{@begin_bracket}#{obj_.points.map { |p_| _generate_coords(p_) }.join(', ')}#{@end_bracket}"
        end
      end

      def _generate_polygon(obj_) # :nodoc:
        if obj_.is_empty?
          "EMPTY"
        else
          "#{@begin_bracket}#{([_generate_line_string(obj_.exterior_ring)] + obj_.interior_rings.map { |r_| _generate_line_string(r_) }).join(', ')}#{@end_bracket}"
        end
      end

      def _generate_geometry_collection(obj_) # :nodoc:
        if obj_.is_empty?
          "EMPTY"
        else
          "#{@begin_bracket}#{obj_.map { |f_| _generate_feature(f_) }.join(', ')}#{@end_bracket}"
        end
      end

      def _generate_multi_point(obj_) # :nodoc:
        if obj_.is_empty?
          "EMPTY"
        else
          "#{@begin_bracket}#{obj_.map { |f_| _generate_point(f_) }.join(', ')}#{@end_bracket}"
        end
      end

      def _generate_multi_line_string(obj_) # :nodoc:
        if obj_.is_empty?
          "EMPTY"
        else
          "#{@begin_bracket}#{obj_.map { |f_| _generate_line_string(f_) }.join(', ')}#{@end_bracket}"
        end
      end

      def _generate_multi_polygon(obj_) # :nodoc:
        if obj_.is_empty?
          "EMPTY"
        else
          "#{@begin_bracket}#{obj_.map { |f_| _generate_polygon(f_) }.join(', ')}#{@end_bracket}"
        end
      end
    end
  end
end
