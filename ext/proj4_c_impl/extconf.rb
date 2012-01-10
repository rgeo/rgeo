# -----------------------------------------------------------------------------
#
# Makefile builder for Proj4 wrapper
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


if ::RUBY_DESCRIPTION =~ /^jruby\s/

  ::File.open('Makefile', 'w'){ |f_| f_.write(".PHONY: install\ninstall:\n") }

else

  require 'mkmf'

  header_dirs_ =
    [
     '/usr/local/include',
     '/usr/local/proj/include',
     '/usr/local/proj4/include',
     '/opt/local/include',
     '/opt/proj/include',
     '/opt/proj4/include',
     '/opt/include',
     '/Library/Frameworks/PROJ.framework/unix/include',
     ::RbConfig::CONFIG['includedir'],
     '/usr/include',
    ]
  lib_dirs_ =
    [
     '/usr/local/lib',
     '/usr/local/proj/lib',
     '/usr/local/proj4/lib',
     '/opt/local/lib',
     '/opt/proj/lib',
     '/opt/proj4/lib',
     '/opt/lib',
     '/Library/Frameworks/PROJ.framework/unix/lib',
     ::RbConfig::CONFIG['libdir'],
     '/usr/lib',
    ]
  header_dirs_.delete_if{ |path_| !::File.directory?(path_) }
  lib_dirs_.delete_if{ |path_| !::File.directory?(path_) }

  found_proj_ = false
  header_dirs_, lib_dirs_ = dir_config('proj', header_dirs_, lib_dirs_)
  if have_header('proj_api.h')
    $libs << ' -lproj'
    if have_func('pj_init_plus', 'proj_api.h')
      found_proj_ = true
    else
      $libs.gsub!(' -lproj', '')
    end
  end
  unless found_proj_
    puts "**** WARNING: Unable to find Proj headers or Proj version is too old."
    puts "**** Compiling without Proj support."
  end
  create_makefile('rgeo/coord_sys/proj4_c_impl')

end
