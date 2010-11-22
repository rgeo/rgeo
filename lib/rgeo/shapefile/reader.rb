# -----------------------------------------------------------------------------
# 
# Shapefile reader for RGeo
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


begin
  require 'dbf'
rescue ::LoadError => ex_
end


module RGeo
  
  module Shapefile
    
    
    # Represents a shapefile that is open for reading.
    # 
    # You can use this object to read a shapefile straight through,
    # yielding the data in a block; or you can perform random access
    # reads of indexed records.
    # 
    # You must close this object after you are done, in order to close
    # the underlying files. Alternatively, you can pass a block to
    # Reader::open, and the reader will be closed automatically for
    # you at the end of the block.
    # 
    # === Dependencies
    # 
    # Attributes in shapefiles are stored in a ".dbf" (dBASE) format
    # file. The "dbf" gem is required to read these files. If this
    # gem is not installed, shapefile reading will still function,
    # but attributes will not be available.
    # 
    # Correct interpretation of the polygon shape type requires some
    # functionality that is available in the RGeo::Geos module. Hence,
    # reading a polygon shapefile will generally fail if that module is
    # not available or the GEOS library is not installed. It is possible
    # to bypass this requirement by relaxing the polygon tests and making
    # some assumptions about the file format. See the documentation for
    # Reader::open for details.
    # 
    # === Shapefile support
    # 
    # This class supports shapefiles formatted according to the 1998
    # "ESRI Shapefile Technical Description". It converts shapefile
    # data to RGeo geometry objects, as follows:
    # 
    # * Shapefile records are represented by the
    #   RGeo::Shapefile::Reader::Record class, which provides the
    #   geometry, the attributes, and the record number (0-based).
    # * Attribute reading is supported by the "dbf" gem, which provides
    #   the proper typecasting for numeric, string, boolean, and
    #   date/time column types. Data in unrecognized column types are
    #   returned as strings.
    # * All shape types documented in the 1998 publication are supported,
    #   including point, polyline, polygon, multipoint, and multipatch,
    #   along with Z and M versions.
    # * Null shapes are translated into nil geometry objects. That is,
    #   Record#geometry will return nil if that record has a null shape.
    # * The point shape type yields Point geometries.
    # * The multipoint shape type yields MultiPoint geometries.
    # * The polyline shape type yields MultiLineString geometries.
    # * The polygon shape type yields MultiPolygon geometries.
    # * The multipatch shape type yields GeometryCollection geometries.
    #   (See below for an explanation of why we do not return a
    #   MultiPolygon.)
    # 
    # Some special notes and limitations in our shapefile support:
    # 
    # * Our implementation assumes that shapefile data is in a Cartesian
    #   coordinate system when it performs certain computations, such as
    #   directionality of polygon rings. It also ignores the 180 degree
    #   longitude seam, so it may not correctly interpret objects whose
    #   coordinates are in lat/lon space and which span that seam.
    # * The ESRI polygon specification allows interior rings to touch
    #   their exterior ring in a finite number of points. This technically
    #   violates the OGC Polygon definition. However, such a structure
    #   remains a legal OGC MultiPolygon, and it is in principle possible
    #   to detect this case and transform the geometry type accordingly.
    #   We do not yet do this. Therefore, it is possible for a shapefile
    #   with polygon type to yield an illegal geometry.
    # * The ESRI polygon specification clearly specifies the winding order
    #   for inner and outer rings: outer rings are clockwise while inner
    #   rings are counterclockwise. We have heard it reported that there
    #   may be shapefiles out there that do not conform to this spec. Such
    #   shapefiles may not read correctly.
    # * The ESRI multipatch specification includes triangle strips and
    #   triangle fans as ways of constructing polygonal patches. We read
    #   in the aggregate polygonal patches, and do not preserve the
    #   individual triangles.
    # * The ESRI multipatch specification allows separate patch parts to
    #   share common boundaries, thus effectively becoming a single
    #   polygon. It is in principle possible to detect this case and
    #   merge the constituent polygons; however, such a data structure
    #   implies that the intent is for such polygons to remain distinct
    #   objects even though they share a common boundary. Therefore, we
    #   do not attempt to merge such polygons. However, this means it is
    #   possible for a multipatch to violate the OGC MultiPolygon
    #   assertions, which do not allow constituent polygons to share a
    #   common boundary. Therefore, when reading a multipatch, we return
    #   a GeometryCollection instead of a MultiPolygon.
    
    class Reader
      
      
      # Values less than this value are considered "no value" in the
      # shapefile format specification.
      NODATA_LIMIT = -1e38
      
      
      # Create a new shapefile reader. You must pass the path for the
      # main shapefile (e.g. "path/to/file.shp"). You may also omit the
      # ".shp" extension from the path. All three files that make up the
      # shapefile (".shp", ".idx", and ".dbf") must be present for
      # successful opening of a shapefile.
      # 
      # If you provide a block, the shapefile reader will be yielded to
      # the block, and automatically closed at the end of the block.
      # If you do not provide a block, the shapefile reader will be
      # returned from this call. It is then the caller's responsibility
      # to close the reader when it is done.
      # 
      # Options include:
      # 
      # <tt>:default_factory</tt>::
      #   The default factory for parsed geometries, used when no factory
      #   generator is provided. If no default is provided either, the
      #   default cartesian factory will be used as the default.
      # <tt>:factory_generator</tt>::
      #   A factory generator that should return a factory based on the
      #   srid and dimension settings in the input. The factory generator
      #   should understand the configuration options
      #   <tt>:support_z_coordinate</tt> and <tt>:support_m_coordinate</tt>.
      #   See RGeo::Features::FactoryGenerator for more information.
      #   If no generator is provided, the <tt>:default_factory</tt> is
      #   used.
      # <tt>:srid</tt>::
      #   If provided, this option is passed to the factory generator.
      #   This is useful because shapefiles do not contain a SRID.
      # <tt>:assume_inner_follows_outer</tt>::
      #   If set to true, some assumptions are made about ring ordering
      #   in a polygon shapefile. See below for details. Default is false.
      # 
      # === Ring ordering in polygon shapefiles
      # 
      # The ESRI polygon shape type specifies that the ordering of rings
      # in the shapefile is not significant. That is, rings can be in any
      # order, and inner rings need not necessarily follow the outer ring
      # they are associated with. This specification causes some headache
      # in the process of constructing polygons from a shapefile, because
      # it becomes necessary to run some geometric analysis on the rings
      # that are read in, in order to determine which inner rings should
      # go with which outer rings.
      # 
      # RGeo's shapefile reader uses GEOS to perform this analysis.
      # However, this means that if GEOS is not available, the analysis
      # will fail. It also means reading polygons may be slow, especially
      # for polygon records with a large number of parts. Therefore, it
      # is possible to turn off this analysis by setting the
      # <tt>:assume_inner_follows_outer</tt> switch when creating a
      # Reader. This causes the shapefile reader to assume that inner
      # rings always follow their corresponding outer ring in the file.
      # This is probably true for most well-behaved shapefiles out there,
      # but since it is not part of the specification, this shortcutting
      # is not turned on by default. However, if you are running RGeo on
      # a platform without GEOS, you have no choice but to turn on this
      # switch and make this assumption about your input shapefiles.
      
      def self.open(path_, opts_={}, &block_)
        file_ = new(path_, opts_)
        if block_
          begin
            yield file_
          ensure
            file_.close
          end
          nil
        else
          file_
        end
      end
      
      
      # Low-level creation of a Reader. The arguments are the same as
      # those passed to Reader::open, except that this doesn't take a
      # block. You should use Reader::open instead.
      
      def initialize(path_, opts_={})  # :nodoc:
        path_.sub!(/\.shp$/, '')
        @base_path = path_
        @opened = true
        @main_file = ::File.open(path_+'.shp', 'rb:ascii-8bit')
        @index_file = ::File.open(path_+'.shx', 'rb:ascii-8bit')
        @attr_dbf = ::DBF::Table.new(path_+'.dbf') rescue nil
        @main_length, @shape_type_code, @xmin, @ymin, @xmax, @ymax, @zmin, @zmax, @mmin, @mmax = @main_file.read(100).unpack('x24Nx4VE8')
        @main_length *= 2
        index_length_ = @index_file.read(100).unpack('x24Nx72').first
        @num_records = (index_length_ - 50) / 4
        @cur_record_index = 0
        
        if @num_records == 0
          @xmin = @xmax = @ymin = @ymax = @zmin = @zmax = @mmin = @mmax = nil
        else
          case @shape_type_code
          when 11, 13, 15, 18, 31
            if @mmin < NODATA_LIMIT || @mmax < NODATA_LIMIT
              @mmin = @mmax = nil
            end
            if @zmin < NODATA_LIMIT || @zmax < NODATA_LIMIT
              @zmin = @zmax = nil
            end
          when 21, 23, 25, 28
            @zmin = @zmax = nil
          else
            @mmin = @mmax = @zmin = @zmax = nil
          end
        end
        
        factory_generator_ = opts_[:factory_generator]
        if factory_generator_
          factory_config_ = {}
          factory_config_[:srid] = opts_[:srid] if opts_[:srid]
          unless @zmin.nil?
            factory_config_[:support_z_coordinate] = true
          end
          unless @mmin.nil?
            factory_config_[:support_m_coordinate] = true
          end
          @factory = factory_generator_.call(factory_config_)
        else
          @factory = opts_[:default_factory] || Cartesian.preferred_factory
        end
        @factory_supports_z = @factory.has_capability?(:z_coordinate)
        @factory_supports_m = @factory.has_capability?(:m_coordinate)
        
        @assume_inner_follows_outer = opts_[:assume_inner_follows_outer]
      end
      
      
      # Close the shapefile.
      # You should not use this Reader after it has been closed.
      # Most methods will return nil.
      
      def close
        if @opened
          @main_file.close
          @index_file.close
          @attr_dbf.close if @attr_dbf
          @opened = false
        end
      end
      
      
      # Returns true if this Reader is still open, or false if it has
      # been closed.
      
      def open?
        @opened
      end
      
      
      # Returns true if attributes are available. This may be false
      # because there is no ".dbf" file or because the dbf gem is not
      # available.
      
      def attributes_available?
        @opened ? (@attr_dbf ? true : false) : nil
      end
      
      
      # Returns the factory used by this reader.
      
      def factory
        @opened ? @factory : nil
      end
      
      
      # Returns the number of records in the shapefile.
      
      def num_records
        @opened ? @num_records : nil
      end
      alias_method :size, :num_records
      
      
      # Returns the shape type code.
      
      def shape_type_code
        @shape_type_code
      end
      
      
      # Returns the minimum x.
      
      def xmin
        @opened ? @xmin : nil
      end
      
      
      # Returns the maximum x.
      
      def xmax
        @opened ? @xmax : nil
      end
      
      
      # Returns the minimum y.
      
      def ymin
        @opened ? @ymin : nil
      end
      
      
      # Returns the maximum y.
      
      def ymax
        @opened ? @ymax : nil
      end
      
      
      # Returns the minimum z, or nil if the shapefile does not contain z.
      
      def zmin
        @opened ? @zmin : nil
      end
      
      
      # Returns the maximum z, or nil if the shapefile does not contain z.
      
      def zmax
        @opened ? @zmax : nil
      end
      
      
      # Returns the minimum m, or nil if the shapefile does not contain m.
      
      def mmin
        @opened ? @mmin : nil
      end
      
      
      # Returns the maximum m, or nil if the shapefile does not contain m.
      
      def mmax
        @opened ? @mmax : nil
      end
      
      
      # Returns the current file pointer as a record index (0-based).
      # This is the record number that will be read when Reader#next
      # is called.
      
      def cur_index
        @opened ? @cur_record_index : nil
      end
      
      
      # Read and return the next record as a Reader::Record.
      
      def next
        @cur_record_index < @num_records ? _read_next_record : nil
      end
      
      
      # Read the remaining records starting with the current record index,
      # and yield the Reader::Record for each one.
      
      def each
        while @cur_record_index < @num_records
          yield _read_next_record
        end
      end
      
      
      # Seek to the given record index.
      
      def seek_index(index_)
        if index_ >= 0 && index_ <= @num_records
          if index_ < @num_records && index_ != @cur_record_index
            @index_file.seek(100+8*index_)
            offset_ = @index_file.read(4).unpack('N').first
            @main_file.seek(offset_*2)
          end
          @cur_record_index = index_
          true
        else
          false
        end
      end
      
      
      # Rewind to the beginning of the file.
      # Equivalent to seek_index(0).
      
      def rewind
        seek_index(0)
      end
      
      
      # Get the given record number. Equivalent to seeking to that index
      # and calling next.
      
      def get(index_)
        seek_index(index_) ? self.next : nil
      end
      alias_method :[], :get
      
      
      def _read_next_record  # :nodoc:
        num_, length_ = @main_file.read(8).unpack('NN')
        data_ = @main_file.read(length_ * 2)
        shape_type_ = data_[0,4].unpack('V').first
        geometry_ =
          case shape_type_
          when 1 then _read_point(data_)
          when 3 then _read_polyline(data_)
          when 5 then _read_polygon(data_)
          when 8 then _read_multipoint(data_)
          when 11 then _read_point(data_, :z)
          when 13 then _read_polyline(data_, :z)
          when 15 then _read_polygon(data_, :z)
          when 18 then _read_multipoint(data_, :z)
          when 21 then _read_point(data_, :m)
          when 23 then _read_polyline(data_, :m)
          when 25 then _read_polygon(data_, :m)
          when 28 then _read_multipoint(data_, :m)
          when 31 then _read_multipatch(data_)
          else nil
          end
        dbf_record_ = @attr_dbf ? @attr_dbf.record(@cur_record_index) : nil
        attrs_ = {}
        attrs_.merge!(dbf_record_.attributes) if dbf_record_
        result_ = Record.new(@cur_record_index, geometry_, attrs_)
        @cur_record_index += 1
        result_
      end
      
      
      def _read_point(data_, opt_=nil)  # :nodoc:
        case opt_
        when :z
          x_, y_, z_, m_ = data_[4,32].unpack('EEEE')
          m_ = 0 if m_.nil? || m_ < NODATA_LIMIT
        when :m
          x_, y_, m_ = data_[4,24].unpack('EEE')
          z_ = 0
        else
          x_, y_ = data_[4,16].unpack('EE')
          z_ = m_ = 0
        end
        extras_ = []
        extras_ << z_ if @factory_supports_z
        extras_ << m_ if @factory_supports_m
        @factory.point(x_, y_, *extras_)
      end
      
      
      def _read_multipoint(data_, opt_=nil)  # :nodoc:
        # Read number of points
        num_points_ = data_[36,4].unpack('V').first
        
        # Read remaining data
        size_ = num_points_*16
        size_ += 16 + num_points_*8 if opt_
        size_ += 16 + num_points_*8 if opt_ == :z
        values_ = data_[40, size_].unpack('E*')
        
        # Extract XY, Z, and M values
        xys_ = values_.slice!(0, num_points_*2)
        ms_ = nil
        zs_ = nil
        if opt_
          ms_ = values_.slice!(2, num_points_)
          if opt_ == :z
            zs_ = ms_
            ms_ = values_.slice!(4, num_points_)
            ms_.map!{ |val_| val_ < NODATA_LIMIT ? 0 : val_ } if ms_
          end
        end
        
        # Generate points
        points_ = (0..num_points_-1).map do |i_|
          extras_ = []
          extras_ << zs_[i_] if zs_ && @factory_supports_z
          extras_ << ms_[i_] if ms_ && @factory_supports_m
          @factory.point(xys_[i_*2], xys_[i_*2+1], *extras_)
        end

        # Return a MultiPoint
        @factory.multi_point(points_)
      end
      
      
      def _read_polyline(data_, opt_=nil)  # :nodoc:
        # Read counts
        num_parts_, num_points_ = data_[36,8].unpack('VV')
        
        # Read remaining data
        size_ = num_parts_*4 + num_points_*16
        size_ += 16 + num_points_*8 if opt_
        size_ += 16 + num_points_*8 if opt_ == :z
        values_ = data_[44, size_].unpack("V#{num_parts_}E*")
        
        # Parts array
        part_indexes_ = values_.slice!(0, num_parts_) + [num_points_]
        
        # Extract XY, Z, and M values
        xys_ = values_.slice!(0, num_points_*2)
        ms_ = nil
        zs_ = nil
        if opt_
          ms_ = values_.slice!(2, num_points_)
          if opt_ == :z
            zs_ = ms_
            ms_ = values_.slice!(4, num_points_)
            ms_.map!{ |val_| val_ < NODATA_LIMIT ? 0 : val_ }
          end
        end
        
        # Generate points
        points_ = (0..num_points_-1).map do |i_|
          extras_ = []
          extras_ << zs_[i_] if zs_ && @factory_supports_z
          extras_ << ms_[i_] if ms_ && @factory_supports_m
          @factory.point(xys_[i_*2], xys_[i_*2+1], *extras_)
        end
        
        # Generate LineString objects (parts)
        parts_ = (0..num_parts_-1).map do |i_|
          @factory.line_string(points_[part_indexes_[i_]...part_indexes_[i_+1]])
        end
        
        # Generate MultiLineString
        @factory.multi_line_string(parts_)
      end
      
      
      def _read_polygon(data_, opt_=nil)  # :nodoc:
        # Read counts
        num_parts_, num_points_ = data_[36,8].unpack('VV')
        
        # Read remaining data
        size_ = num_parts_*4 + num_points_*16
        size_ += 16 + num_points_*8 if opt_
        size_ += 16 + num_points_*8 if opt_ == :z
        values_ = data_[44, size_].unpack("V#{num_parts_}E*")
        
        # Parts array
        part_indexes_ = values_.slice!(0, num_parts_) + [num_points_]
        
        # Extract XY, Z, and M values
        xys_ = values_.slice!(0, num_points_*2)
        ms_ = nil
        zs_ = nil
        if opt_
          ms_ = values_.slice!(2, num_points_)
          if opt_ == :z
            zs_ = ms_
            ms_ = values_.slice!(4, num_points_)
            ms_.map!{ |val_| val_ < NODATA_LIMIT ? 0 : val_ } if ms_
          end
        end
        
        # Generate points
        points_ = (0..num_points_-1).map do |i_|
          extras_ = []
          extras_ << zs_[i_] if zs_ && @factory_supports_z
          extras_ << ms_[i_] if ms_ && @factory_supports_m
          @factory.point(xys_[i_*2], xys_[i_*2+1], *extras_)
        end
        
        # The parts are LinearRing objects
        parts_ = (0..num_parts_-1).map do |i_|
          @factory.linear_ring(points_[part_indexes_[i_]...part_indexes_[i_+1]])
        end
        
        # Get a GEOS factory if needed.
        geos_factory_ = nil
        unless @assume_inner_follows_outer
          geos_factory_ = Geos.factory
          unless geos_factory_
            raise Errors::RGeoError, "GEOS is not available, but is required for correct interpretation of polygons in shapefiles."
          end
        end
        
        # Special case: if there's only one part, treat it as an outer
        # ring, regardless of its direction. This isn't strictly compliant
        # with the shapefile spec, but the shapelib test cases seem to
        # include this case, so we'll relax the assertions here.
        if parts_.size == 1
          return @factory.multi_polygon([@factory.polygon(parts_[0])])
        end
        
        # Collect some data on the rings: the ring direction, a GEOS
        # polygon (for intersection calculation), and an initial guess
        # of which polygon index the ring belongs to.
        parts_.map! do |ring_|
          [ring_, Cartesian::Analysis.ring_direction(ring_) < 0, geos_factory_ ? geos_factory_.polygon(ring_) : nil, nil]
        end
        
        # Initial population of the polygon data array.
        # Each element is an array of the part data for the rings, first
        # the outer ring and then the inner rings.
        # Here we populate the outer rings, and we do an initial
        # assignment of rings to polygon index. The initial guess is that
        # inner rings always follow their outer ring.
        polygons_ = []
        parts_.each do |part_data_|
          if part_data_[1]
            polygons_ << [part_data_]
          elsif @assume_inner_follows_outer && polygons_.size > 0
            polygons_.last << part_data_
          end
          part_data_[3] = polygons_.size - 1
        end
        
        # If :assume_inner_follows_outer is in effect, we assume this
        # initial guess is the correct one, and we don't run the
        # potentially expensive intersection tests.
        unless @assume_inner_follows_outer
          case polygons_.size
          when 0
            # Skip this algorithm if there's no outer
          when 1
            # Shortcut if there's only one outer. Assume all the inners
            # are members of this one polygon.
            parts_.each do |part_data_|
              unless part_data_[1]
                polygons_[0] << part_data_
              end
            end
          else
            # Go through the remaining (inner) rings, and assign them to
            # the correct polygon. For each inner ring, we find the outer
            # ring containing it, and add it to that polygon's data. We
            # check the initial guess first, and if it fails we go through
            # the remaining polygons in order.
            parts_.each do |part_data_|
              unless part_data_[1]
                # This will hold the polygon index for this inner ring.
                parent_index_ = nil
                # The initial guess. It could be -1 if this inner ring
                # appeared before any outer rings had appeared.
                first_try_ = part_data_[3]
                if first_try_ >= 0 && part_data_[2].within?(polygons_[first_try_].first[2])
                  parent_index_ = first_try_
                end
                # If the initial guess didn't work, go through the
                # remaining polygons and check their outer rings.
                unless parent_index_
                  polygons_.each_with_index do |poly_data_, index_|
                    if index_ != first_try_ && part_data_[2].within?(poly_data_.first[2])
                      parent_index_ = index_
                      break
                    end
                  end
                end
                # If we found a match, append this inner ring to that
                # polygon data. Otherwise, just throw away the inner ring.
                if parent_index_
                  polygons_[parent_index_] << part_data_
                end
              end
            end
          end
        end
        
        # Generate the actual polygons from the collected polygon data
        polygons_.map! do |poly_data_|
          outer_ = poly_data_[0][0]
          inner_ = poly_data_[1..-1].map{ |part_data_| part_data_[0] }
          @factory.polygon(outer_, inner_)
        end
        
        # Finally, return the MultiPolygon.
        @factory.multi_polygon(polygons_)
      end
      
      
      def _read_multipatch(data_)  # :nodoc:
        # Read counts
        num_parts_, num_points_ = data_[36,8].unpack('VV')
        
        # Read remaining data
        values_ = data_[44, 32 + num_parts_*8 + num_points_*32].unpack("V#{num_parts_*2}E*")
        
        # Parts arrays
        part_indexes_ = values_.slice!(0, num_parts_) + [num_points_]
        part_types_ = values_.slice!(0, num_parts_)
        
        # Extract XY, Z, and M values
        xys_ = values_.slice!(0, num_points_*2)
        zs_ = values_.slice!(2, num_points_)
        zs_.map!{ |val_| val_ < NODATA_LIMIT ? 0 : val_ } if zs_
        ms_ = values_.slice!(4, num_points_)
        ms_.map!{ |val_| val_ < NODATA_LIMIT ? 0 : val_ } if ms_
        
        # Generate points
        points_ = (0..num_points_-1).map do |i_|
          extras_ = []
          extras_ << zs_[i_] if zs_ && @factory_supports_z
          extras_ << ms_[i_] if ms_ && @factory_supports_m
          @factory.point(xys_[i_*2], xys_[i_*2+1], *extras_)
        end
        
        # Create the parts
        parts_ = (0..num_parts_-1).map do |i_|
          ps_ = points_[part_indexes_[i_]...part_indexes_[i_+1]]
          # All part types just translate directly into rings, except for
          # triangle fan, which requires that we reorder the vertices.
          if part_types_[i_] == 0
            ps2_ = []
            i2_ = 0
            while i2_ < ps_.size
              ps2_ << ps_[i2_]
              i2_ += 2
            end
            i2_ -= 1
            i2_ -= 2 if i2_ >= ps_.size
            while i2_ > 0
              ps2_ << ps_[i2_]
              i2_ -= 2
            end
            ps_ = ps2_
          end
          @factory.linear_ring(ps_)
        end
        
        # Get a GEOS factory if needed.
        geos_factory_ = nil
        unless @assume_inner_follows_outer
          geos_factory_ = Geos.factory
          unless geos_factory_
            raise Errors::RGeoError, "GEOS is not available, but is required for correct interpretation of polygons in shapefiles."
          end
        end
        
        # Walk the parts and generate polygons
        polygons_ = []
        state_ = :empty
        sequence_ = []
        # We deliberately include num_parts_ so there's an extra iteration
        # with a null part_ and type_. This is so the state handling block
        # can finish up any currently live sequence.
        (0..num_parts_).each do |index_|
          part_ = parts_[index_]
          type_ = part_types_[index_]
          
          # This section handles any state.
          # It either stays in the state and goes to the next part,
          # or it wraps up the state. Either way, at the end of this
          # case block, the state must be :empty.
          case state_
          when :outer
            if type_ == 3
              # Inner ring in an outer-led sequence.
              # Just add it to the sequence and continue.
              sequence_ << part_
              next
            else
              # End of an outer-led sequence.
              # Add the polygon and reset the state.
              polygons_ << @factory.polygon(sequence_[0], sequence_[1..-1])
              state_ = :empty
              sequence_ = []
            end
          when :first
            if type_ == 5
              # Unknown ring in a first-led sequence.
              # Just add it to the sequence and continue.
              sequence_ << part_
            else
              # End of a first-led sequence.
              # Need to determine which is the outer ring before we can
              # add the polygon.
              # If :assume_inner_follows_outer is in effect, we assume
              # the first ring is the outer one. Otherwise, we have to
              # use GEOS to determine containment.
              unless @assume_inner_follows_outer
                geos_polygons_ = sequence_.map{ |ring_| geos_factory_.polygon(ring_) }
                outer_poly_ = nil
                outer_index_ = 0
                geos_polygons_.each_with_index do |poly_, index_|
                  if outer_poly_
                    if poly_.contains?(outer_poly_)
                      outer_poly_ = poly_
                      outer_index_ = index_
                      break;
                    end
                  else
                    outer_poly_ = poly_
                  end
                end
                sequence_.slice!(outer_index_)
                sequence_.unshift(outer_poly_)
              end
              polygons_ << @factory.polygon(sequence_[0], sequence_[1..-1])
              state_ = :empty
              sequence_ = []
            end
          end
          
          # State is now :empty. We allow any type except 3 (since an
          # (inner must come during an outer-led sequence).
          # We treat a type 5 ring that isn't part of a first-led sequence
          # as an outer ring.
          case type_
          when 0, 1
            polygons_ << @factory.polygon(part_)
          when 2, 5
            sequence_ << part_
            state_ = :outer
          when 4
            sequence_ << part_
            state_ = :first
          end
        end
        
        # Return the geometry as a collection.
        @factory.collection(polygons_)
      end
      
      
      # Shapefile records are provided to the caller as objects of this
      # type. The record includes the record index (0-based), the
      # geometry (which may be nil if the shape type is the null type),
      # and a hash of attributes from the associated dbf file.
      # 
      # You should not need to create objects of this type yourself.
      
      class Record
        
        def initialize(index_, geometry_, attributes_)  # :nodoc:
          @index = index_
          @geometry = geometry_
          @attributes = attributes_
        end
        
        # The 0-based record number
        attr_reader :index
        
        # The geometry contained in this shapefile record
        attr_reader :geometry
        
        # The attributes as a hash.
        attr_reader :attributes
        
        # Returns an array of keys for all this record's attributes.
        def keys
          @attributes.keys
        end
        
        # Returns the value for the given attribute key.
        def [](key_)
          @attributes[key_]
        end
        
      end
      
      
    end
    
    
  end
  
end
