# -----------------------------------------------------------------------------
#
# Makefile builder for Proj4 wrapper
#
# -----------------------------------------------------------------------------

if ::RUBY_DESCRIPTION =~ /^jruby\s/

  ::File.open("Makefile", "w") { |f_| f_.write(".PHONY: install\ninstall:\n") }

else

  require "mkmf"

  header_dirs_ =
    [
      ::RbConfig::CONFIG["includedir"],
      "/usr/local/include",
      "/usr/local/proj/include",
      "/usr/local/proj4/include",
      "/opt/local/include",
      "/opt/proj/include",
      "/opt/proj4/include",
      "/opt/include",
      "/Library/Frameworks/PROJ.framework/unix/include",
      "/usr/include"
    ]
  lib_dirs_ =
    [
      ::RbConfig::CONFIG["libdir"],
      "/usr/local/lib",
      "/usr/local/lib64",
      "/usr/local/proj/lib",
      "/usr/local/proj4/lib",
      "/opt/local/lib",
      "/opt/proj/lib",
      "/opt/proj4/lib",
      "/opt/lib",
      "/Library/Frameworks/PROJ.framework/unix/lib",
      "/usr/lib",
      "/usr/lib64"
    ]
  header_dirs_.delete_if { |path_| !::File.directory?(path_) }
  lib_dirs_.delete_if { |path_| !::File.directory?(path_) }

  found_proj_ = false
  header_dirs_, lib_dirs_ = dir_config("proj", header_dirs_, lib_dirs_)
  if have_header("proj_api.h")
    $libs << " -lproj"
    if have_func("pj_init_plus", "proj_api.h")
      found_proj_ = true
    else
      $libs.gsub!(" -lproj", "")
    end
  end
  unless found_proj_
    puts "**** WARNING: Unable to find Proj headers or Proj version is too old."
    puts "**** Compiling without Proj support."
  end
  create_makefile("rgeo/coord_sys/proj4_c_impl")

end
