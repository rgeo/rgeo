# -----------------------------------------------------------------------------
#
# Makefile builder for GEOS wrapper
#
# -----------------------------------------------------------------------------

if ::RUBY_DESCRIPTION =~ /^jruby\s/

  ::File.open('Makefile', 'w'){ |f_| f_.write(".PHONY: install\ninstall:\n") }

else

  require 'mkmf'

  header_dirs_ =
    [
     '/usr/local/include',
     '/usr/local/geos/include',
     '/opt/local/include',
     '/opt/geos/include',
     '/opt/include',
     '/Library/Frameworks/GEOS.framework/unix/include',
     ::RbConfig::CONFIG['includedir'],
     '/usr/include',
    ]
  lib_dirs_ =
    [
     '/usr/local/lib64',
     '/usr/local/lib',
     '/usr/local/geos/lib',
     '/opt/local/lib',
     '/opt/geos/lib',
     '/opt/lib',
     '/Library/Frameworks/GEOS.framework/unix/lib',
     ::RbConfig::CONFIG['libdir'],
     '/usr/lib64',
     '/usr/lib',
    ]
  header_dirs_.delete_if{ |path_| !::File.directory?(path_) }
  lib_dirs_.delete_if{ |path_| !::File.directory?(path_) }

  found_geos_ = false
  header_dirs_, lib_dirs_ = dir_config('geos', header_dirs_, lib_dirs_)
  if have_header('geos_c.h')
    $libs << ' -lgeos -lgeos_c'
    if have_func('GEOSSetSRID_r', 'geos_c.h')
      found_geos_ = true
    else
      $libs.gsub!(' -lgeos -lgeos_c', '')
    end
    have_func('GEOSPreparedContains_r', 'geos_c.h')
    have_func('GEOSPreparedDisjoint_r', 'geos_c.h')
    have_func('GEOSWKTWriter_setOutputDimension_r', 'geos_c.h')
    have_func('GEOSUnaryUnion_r', 'geos_c.h')
    have_func('rb_memhash', 'ruby.h')
  end
  unless found_geos_
    puts "**** WARNING: Unable to find GEOS headers or GEOS version is too old."
    puts "**** Compiling without GEOS support."
  end
  create_makefile('rgeo/geos/geos_c_impl')

end
