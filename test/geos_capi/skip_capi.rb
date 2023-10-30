# frozen_string_literal: true

module SkipCAPI
  def setup
    skip "Needs GEOS CAPI." unless RGeo::Geos.capi_supported?
    super
  end

  def skip_geos_version_less_then(version)
    return if Gem::Version.new(RGeo::Geos.version) >= Gem::Version.new(version)

    skip "Needs GEOS version #{version} or later."
  end
end
