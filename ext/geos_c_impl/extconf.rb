# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Makefile builder for GEOS wrapper
#
# -----------------------------------------------------------------------------
def create_dummy_makefile
  File.write("Makefile", ".PHONY: install\ninstall:\n")
end

if RUBY_DESCRIPTION =~ /^jruby\s/
  create_dummy_makefile
  exit
end

require "mkmf"

if ENV.key?("DEBUG") || ENV.key?("MAINTAINER_MODE")
  $CFLAGS << " -DDEBUG" \
             " -Wall" \
             " -ggdb" \
             " -pedantic" \
             " -std=c17"

  extra_flags = ENV.fetch("MAINTAINER_MODE", ENV.fetch("DEBUG", ""))
  $CFLAGS << " " << extra_flags if extra_flags.strip.start_with?("-")
end

geosconfig = with_config("geos-config") || find_executable("geos-config")

if geosconfig
  puts "Using GEOS compile configuration from #{geosconfig}"
  $INCFLAGS << " " << IO.popen([geosconfig, "--cflags"], &:read).strip
  geos_libs = IO.popen([geosconfig, "--clibs"], &:read)
  geos_libs.split.each do |flag|
    $libs << " " << flag unless $libs.include?(flag)
  end
end

found_geos = false
if have_header("geos_c.h")
  # Minimum: GEOS 3.14+ (has GEOSCoordSeq_setM for native M-coordinate support)
  # GEOSCoordSeq_setM, GEOSCoordSeq_getM, and GEOSLineSubstring were all added in 3.14
  found_geos = true if have_func("GEOSCoordSeq_setM", "geos_c.h")

  # Optional: Additional GEOS 3.14+ features (detected for conditional compilation)
  # These may not be present in all 3.14 builds
  have_func("GEOSClusterDBSCAN", "geos_c.h")
  have_func("GEOSCoverageIsValid", "geos_c.h")
  have_func("GEOSisSimpleDetail", "geos_c.h")
  have_func("GEOSLineSubstring", "geos_c.h")

  have_func("rb_memhash", "ruby.h")
  have_func("rb_gc_mark_movable", "ruby.h")
end

if found_geos
  create_makefile("rgeo/geos/geos_c_impl")
else
  puts "**** WARNING: Unable to find GEOS 3.14+ or later."
  puts "**** This version of rgeo requires GEOS 3.14.0 or later for M-coordinate support."
  puts "**** Please upgrade GEOS or use an older version of rgeo (3.0.x supports older GEOS)."
  puts "**** See https://libgeos.org for GEOS installation."

  create_dummy_makefile
end
