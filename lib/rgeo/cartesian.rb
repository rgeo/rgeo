# frozen_string_literal: true

# The Cartesian module is a gateway to implementations that use the
# Cartesian (i.e. flat) coordinate system. It provides convenient
# access to Cartesian factories such as the Geos implementation and
# the simple Cartesian implementation. It also provides a namespace
# for Cartesian-specific analysis tools.

require_relative "cartesian/calculations"
require_relative "cartesian/feature_methods"
require_relative "cartesian/feature_classes"
require_relative "cartesian/factory"
require_relative "cartesian/interface"
require_relative "cartesian/bounding_box"
require_relative "cartesian/analysis"
