# -----------------------------------------------------------------------------
# 
# SRS database interface
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
    
    module SRSDatabase
      
      
      class Proj4Data
        
        
        def initialize(path_, opts_={})
          dir_ = nil
          if opts_.include?(:dir)
            dir_ = opts_[:dir]
          else
            ['/usr/local/share/proj', '/usr/local/proj/share/proj', '/usr/local/proj4/share/proj', '/opt/local/share/proj', '/opt/proj/share/proj', '/opt/proj4/share/proj', '/opt/share/proj', '/usr/share/proj'].each do |d_|
              if ::File.directory?(d_) && ::File.readable?(d_)
                dir_ = d_
                break
              end
            end
          end
          @path = dir_ ? "#{dir_}/#{path_}" : path_
          @cache = opts_[:cache] ? {} : nil
          @authority = opts_[:authority]
          @populate_state = @cache && opts_[:read_all] ? 1 : 0
        end
        
        
        def get(ident_)
          ident_ = ident_.to_s
          return @cache[ident_] if @cache && @cache.include?(ident_)
          result_ = nil
          if @populate_state == 0
            data_ = _search_file(ident_)
            unless data_
              @cache[ident_] = nil if @cache
              return nil
            end
            result_ = Entry.new(ident_, :authority => @authority, :authority_code => @authority ? ident_ : nil, :name => data_[1], :proj4 => data_[2])
            @cache[ident_] = result_ if @cache
          elsif @populate_state == 1
            _search_file(nil) do |id_, name_, text_|
              @cache[id_] = Entry.new(id_, :authority => @authority, :authority_code => @authority ? id_ : nil, :name => name_, :proj4 => text_)
              result_ = @cache[id_] if id_ == ident_
            end
            @populate_state = 2
          end
          result_
        end
        
        
        def clear_cache
          @cache.clear if @cache
          @populate_state = 1 if @populate_state == 2
        end
        
        
        def _search_file(ident_)  # :nodoc:
          ::File.open(@path) do |file_|
            cur_name_ = nil
            cur_ident_ = nil
            cur_text_ = nil
            file_.each do |line_|
              line_.strip!
              if (comment_delim_ = line_.index('#'))
                cur_name_ = line_[comment_delim_+1..-1].strip
                line_ = line_[0..comment_delim_-1].strip
              end
              unless cur_ident_
                if line_ =~ /^<(\w+)>(.*)/
                  cur_ident_ = $1
                  cur_text_ = []
                  line_ = $2.strip
                end
              end
              if cur_ident_
                if line_[-2..-1] == '<>'
                  cur_text_ << line_[0..-3].strip
                  cur_text_ = cur_text_.join(' ')
                  if block_given?
                    yield(ident_, cur_name_, cur_text_)
                  end
                  if cur_ident_ == ident_
                    return [ident_, cur_name_, cur_text_]
                  end
                  cur_ident_ = nil
                  cur_name_ = nil
                  cur_text_ = nil
                else
                  cur_text_ << line_
                end
              end
            end
          end
          nil
        end
        
        
      end
      
      
    end
    
  end
  
end
