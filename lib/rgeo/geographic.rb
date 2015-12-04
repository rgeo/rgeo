# -----------------------------------------------------------------------------
#
# Geographic data for RGeo
#
# -----------------------------------------------------------------------------

module RGeo
  # The Geographic implementation actually comprises a suite of
  # implementations with one common feature: they represent geographic
  # latitude/longitude coordinates measured in degrees. The "x"
  # coordinate corresponds to longitude, and the "y" coordinate to
  # latitude. Thus, coordinates are often expressed in reverse
  # (i.e. long-lat) order. e.g.
  #
  #  location = geographic_factory.point(long, lat)
  #
  # Some geographic implementations include a secondary factory that
  # represents a projection. For these implementations, you can quickly
  # transform data between lat/long coordinates and the projected
  # coordinate system, and most calculations are done in the projected
  # coordinate system. For implementations that do not include this
  # secondary projection factory, calculations are done on the sphereoid.
  # See the various class methods of Geographic for more information on
  # the behaviors of the factories they generate.

  module Geographic
  end
end

# Implementation files.
require "rgeo/geographic/factory"
require "rgeo/geographic/projected_window"
require "rgeo/geographic/interface"
require "rgeo/geographic/spherical_math"
require "rgeo/geographic/spherical_feature_methods"
require "rgeo/geographic/spherical_feature_classes"
require "rgeo/geographic/proj4_projector"
require "rgeo/geographic/simple_mercator_projector"
require "rgeo/geographic/projected_feature_methods"
require "rgeo/geographic/projected_feature_classes"
