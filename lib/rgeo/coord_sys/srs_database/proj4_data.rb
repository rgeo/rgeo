# -----------------------------------------------------------------------------
#
# SRS database interface
#
# -----------------------------------------------------------------------------

module RGeo
  module CoordSys
    module SRSDatabase
      # A spatial reference database implementation backed by coordinate
      # system files installed as part of the proj4 library. For a given
      # Proj4Data object, you specify a single file (e.g. the epsg data
      # file), and you can retrieve records by ID number.

      class Proj4Data
        # Connect to one of the proj4 data files. You should provide the
        # file name, optionally the installation directory if it is not
        # in a typical location, and several additional options.
        #
        # These options are recognized:
        #
        # [<tt>:dir</tt>]
        #   The path for the share/proj directory that contains the
        #   requested data file. By default, the Proj4Data class will
        #   try a number of directories for you, including
        #   /usr/local/share/proj, /opt/local/share/proj, /usr/share/proj,
        #   and a few other variants. However, if you have proj4 installed
        #   elsewhere, you can provide an explicit directory using this
        #   option. You may also pass nil as the value, in which case all
        #   the normal lookup paths will be disabled, and you will have to
        #   provide the full path as the file name.
        # [<tt>:cache</tt>]
        #   If set to true, this class caches previously looked up entries
        #   so subsequent lookups do not have to reread the file. If set
        #   to <tt>:read_all</tt>, then ALL values in the file are read in
        #   and cached the first time a lookup is done. If set to
        #   <tt>:preload</tt>, then ALL values in the file are read in
        #   immediately when the database is created. Default is false,
        #   indicating that the file will be reread on every lookup.
        # [<tt>:authority</tt>]
        #   If set, its value is taken as the authority name for all
        #   entries. The authority code will be set to the identifier. If
        #   not set, then the authority fields of entries will be blank.

        def initialize(filename_, opts_ = {})
          dir_ = nil
          if opts_.include?(:dir)
            dir_ = opts_[:dir]
          else
            ["/usr/local/share/proj", "/usr/local/proj/share/proj", "/usr/local/proj4/share/proj", "/opt/local/share/proj", "/opt/proj/share/proj", "/opt/proj4/share/proj", "/opt/share/proj", "/usr/share/proj"].each do |d_|
              if ::File.directory?(d_) && ::File.readable?(d_)
                dir_ = d_
                break
              end
            end
          end
          @path = dir_ ? "#{dir_}/#{filename_}" : filename_
          @authority = opts_[:authority]
          if opts_[:cache]
            @cache = {}
            case opts_[:cache]
            when :read_all
              @populate_state = 1
            when :preload
              _search_file(nil)
              @populate_state = 2
            else
              @populate_state = 0
            end
          else
            @cache = nil
            @populate_state = 0
          end
        end

        # Retrieve the Entry for the given ID number.

        def get(ident_)
          ident_ = ident_.to_s
          return @cache[ident_] if @cache && @cache.include?(ident_)
          result_ = nil
          if @populate_state == 0
            data_ = _search_file(ident_)
            result_ = Entry.new(ident_, authority: @authority, authority_code: @authority ? ident_ : nil, name: data_[1], proj4: data_[2]) if data_
            @cache[ident_] = result_ if @cache
          elsif @populate_state == 1
            _search_file(nil)
            result_ = @cache[ident_]
            @populate_state = 2
          end
          result_
        end

        # Clear the cache if one exists.

        def clear_cache
          @cache.clear if @cache
          @populate_state = 1 if @populate_state == 2
        end

        def _search_file(ident_) # :nodoc:
          ::File.open(@path) do |file_|
            cur_name_ = nil
            cur_ident_ = nil
            cur_text_ = nil
            file_.each do |line_|
              line_.strip!
              if (comment_delim_ = line_.index('#'))
                cur_name_ = line_[comment_delim_ + 1..-1].strip
                line_ = line_[0..comment_delim_ - 1].strip
              end
              unless cur_ident_
                if line_ =~ /^<(\w+)>(.*)/
                  cur_ident_ = Regexp.last_match(1)
                  cur_text_ = []
                  line_ = Regexp.last_match(2).strip
                end
              end
              next unless cur_ident_
              if line_[-2..-1] == "<>"
                cur_text_ << line_[0..-3].strip
                cur_text_ = cur_text_.join(" ")
                if ident_.nil?
                  @cache[ident_] = Entry.new(ident_, authority: @authority, authority_code: @authority ? id_ : nil, name: cur_name_, proj4: cur_text_)
                end
                return [ident_, cur_name_, cur_text_] if cur_ident_ == ident_
                cur_ident_ = nil
                cur_name_ = nil
                cur_text_ = nil
              else
                cur_text_ << line_
              end
            end
          end
          nil
        end
      end
    end
  end
end
