# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Makefile builder for GEOS wrapper
#
# -----------------------------------------------------------------------------
def create_dummy_makefile
  File.write("Makefile", ".PHONY: install\ninstall:\n")
end

def build_from_library(lib_dir)
  # ensure lib_dir has priority over system directories
  $LIBPATH = [lib_dir]

  # NOTE: due to how find_library works, if lib_dir does not contain the library
  # and you have libgeos installed on your system, it will silently use the system libgeos.
  found_geos = false
  if find_library("geos_c", nil, lib_dir)
    # add macro manually
    $defs << "-DHAVE_GEOS_C_H"
    found_geos = true if have_func("GEOSSetSRID_r")

    have_func("GEOSPreparedContains_r")
    have_func("GEOSPreparedDisjoint_r")
    have_func("GEOSUnaryUnion_r")
    have_func("GEOSCoordSeq_isCCW_r")
    have_func("rb_memhash", "ruby.h")
  end

  if found_geos
    create_makefile("rgeo/geos/geos_c_impl")
  else
    puts "**** WARNING: Unable to find GEOS library from the specified path."
    puts "**** Ensure that the libgeos_c is in the directory you specified."
    puts "**** Compiling without GEOS support."

    create_dummy_makefile
  end
end

def build_from_geos_config
  geosconfig = with_config("geos-config") || find_executable("geos-config")

  if geosconfig
    puts "Using GEOS compile configuration from #{geosconfig}"
    $INCFLAGS << " " << `#{geosconfig} --cflags`.strip
    geos_libs = `#{geosconfig} --clibs`.tr("\n", " ")
    geos_libs.split(/\s+/).each do |flag|
      $libs << " " + flag unless $libs.include?(flag)
    end
  end

  found_geos = false
  if have_header("geos_c.h")
    found_geos = true if have_func("GEOSSetSRID_r", "geos_c.h")
    have_func("GEOSPreparedContains_r", "geos_c.h")
    have_func("GEOSPreparedDisjoint_r", "geos_c.h")
    have_func("GEOSUnaryUnion_r", "geos_c.h")
    have_func("GEOSCoordSeq_isCCW_r", "geos_c.h")
    have_func("rb_memhash", "ruby.h")
  end

  if found_geos
    create_makefile("rgeo/geos/geos_c_impl")
  else
    puts "**** WARNING: Unable to find GEOS headers or libraries."
    puts "**** Ensure that 'geos-config' is in your PATH or provide that full path via --with-geos-config"
    puts "**** Compiling without GEOS support."

    create_dummy_makefile
  end
end

if RUBY_DESCRIPTION =~ /^jruby\s/
  create_dummy_makefile
elsif ENV["RGEO_GEOS_LIB_DIR"]
  require "mkmf"
  build_from_library(ENV["RGEO_GEOS_LIB_DIR"])
else
  require "mkmf"
  build_from_geos_config
end
