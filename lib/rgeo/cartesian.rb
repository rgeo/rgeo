# -----------------------------------------------------------------------------
#
# Cartesian features for RGeo
#
# -----------------------------------------------------------------------------

module RGeo
  # The Cartesian module is a gateway to implementations that use the
  # Cartesian (i.e. flat) coordinate system. It provides convenient
  # access to Cartesian factories such as the Geos implementation and
  # the simple Cartesian implementation. It also provides a namespace
  # for Cartesian-specific analysis tools.

  module Cartesian
  end
end

# Implementation files.
require "rgeo/cartesian/calculations"
require "rgeo/cartesian/feature_methods"
require "rgeo/cartesian/feature_classes"
require "rgeo/cartesian/factory"
require "rgeo/cartesian/interface"
require "rgeo/cartesian/bounding_box"
require "rgeo/cartesian/analysis"
