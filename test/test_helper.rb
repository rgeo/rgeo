# frozen_string_literal: true

# Ensure that we cleanup every object before comparing with valgrind.
at_exit { GC.start } if ENV["LD_PRELOAD"]&.include? "valgrind"

require "minitest/autorun"
require_relative "../lib/rgeo"
require "psych"

# Only here for Psych 4.0.0 breaking change.
# See https://github.com/ruby/psych/pull/487
def psych_load(*args)
  if Psych.respond_to?(:unsafe_load)
    Psych.unsafe_load(*args)
  else
    Psych.load(*args)
  end
end

require_relative "common/factory_tests"
require_relative "common/geometry_collection_tests"
require_relative "common/line_string_tests"
require_relative "common/multi_line_string_tests"
require_relative "common/multi_point_tests"
require_relative "common/multi_polygon_tests"
require_relative "common/point_tests"
require_relative "common/polygon_tests"
require_relative "common/validity_tests"

# Static test for missed references in our CAPI codebase (or FFI interface).
# See https://alanwu.space/post/check-compaction/
if defined?(GC.verify_compaction_references) == "method"
  GC.verify_compaction_references(double_heap: true, toward: :empty)
end

# Live test for our implementation of Ruby's compaction methods (rb_gc_mark_movable
# and rb_gc_location), enabling compaction for every major collection.
if defined?(GC.auto_compact) == "method"
  GC.auto_compact = true
end

# Basic test class where transformations will translate
# based on difference between "value" attribute
class TestAffineCoordinateSystem < RGeo::CoordSys::CS::CoordinateSystem
  def initialize(value, dimension, *optional)
    super(value, dimension, *optional)
    @value = value
  end
  attr_accessor :value

  def transform_coords(target_cs, x, y, z = nil)
    ct = TestAffineCoordinateTransform.create(self, target_cs)
    ct.transform_coords(x, y, z)
  end

  class << self
    def create(value, dimension = 2)
      new(value, dimension)
    end
  end
end

class TestAffineCoordinateTransform < RGeo::CoordSys::CS::CoordinateTransform
  def transform_coords(x, y, z = nil)
    diff = target_cs.value - source_cs.value
    coords = [x + diff, y + diff]
    coords << (z + diff) if z
    coords
  end
end
