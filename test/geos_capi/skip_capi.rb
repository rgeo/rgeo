# frozen_string_literal: true

module SkipCAPI
  def setup
    skip "Needs GEOS CAPI." unless RGeo::Geos.capi_supported?
    super
  end
end
