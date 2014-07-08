# -----------------------------------------------------------------------------
#
# Makefile builder for GEOS wrapper
#
# -----------------------------------------------------------------------------

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
