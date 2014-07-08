# -----------------------------------------------------------------------------
#
# Makefile builder for GEOS wrapper
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

  if geosconfig = (with_config('geos-config') || find_executable('geos-config'))
    puts "Using GEOS compile configuration from %s" [ geosconfig ]
    $INCFLAGS << " " << `#{geosconfig} --cflags`.strip
    geos_libs = `#{geosconfig} --libs --clibs`.gsub("\n", " ")
    geos_libs.split(/\s+/).each do |flag|
      $libs << ' ' + flag unless $libs.include?(flag)
    end
  end

  found_geos_ = false
  if have_header('geos_c.h')
    if have_func('GEOSSetSRID_r', 'geos_c.h')
      found_geos_ = true
    end
    have_func('GEOSPreparedContains_r', 'geos_c.h')
    have_func('GEOSPreparedDisjoint_r', 'geos_c.h')
    have_func('rb_memhash', 'ruby.h')
  end

  unless found_geos_
    puts "**** WARNING: Unable to find GEOS headers or libraries."
    puts "**** Ensure that 'geos-config' is in your PATH or provide that full path via --with-geos-config"
    puts "**** Compiling without GEOS support."
  end

  create_makefile('rgeo/geos/geos_c_impl')
end
