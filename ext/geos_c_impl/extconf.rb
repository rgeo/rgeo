# -----------------------------------------------------------------------------
#
# Makefile builder for GEOS wrapper
#
# -----------------------------------------------------------------------------
def create_dummy_makefile
  ::File.open("Makefile", "w") { |f_| f_.write(".PHONY: install\ninstall:\n") }
end

if ::RUBY_DESCRIPTION =~ /^jruby\s/
  create_dummy_makefile
else
  require "mkmf"

  geosconfig = with_config("geos-config") || find_executable("geos-config")

  if geosconfig
    puts "Using GEOS compile configuration from %s" [geosconfig]
    $INCFLAGS << " " << `#{geosconfig} --cflags`.strip
    geos_libs = `#{geosconfig} --clibs`.tr("\n", " ")
    geos_libs.split(/\s+/).each do |flag|
      $libs << " " + flag unless $libs.include?(flag)
    end
  end

  found_geos_ = false
  if have_header("geos_c.h")
    found_geos_ = true if have_func("GEOSSetSRID_r", "geos_c.h")
    have_func("GEOSPreparedContains_r", "geos_c.h")
    have_func("GEOSPreparedDisjoint_r", "geos_c.h")
    have_func("GEOSUnaryUnion_r", "geos_c.h")
    have_func("rb_memhash", "ruby.h")
  end

  if found_geos_
    create_makefile("rgeo/geos/geos_c_impl")
  else
    puts "**** WARNING: Unable to find GEOS headers or libraries."
    puts "**** Ensure that 'geos-config' is in your PATH or provide that full path via --with-geos-config"
    puts "**** Compiling without GEOS support."

    create_dummy_makefile
  end
end
