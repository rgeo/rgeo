# frozen_string_literal: true

module SkipFFI
  def setup
    skip "Needs GEOS FFI." unless RGeo::Geos.ffi_supported?
    super
  end
end
