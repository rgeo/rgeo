# frozen_string_literal: true

# Ensure that we cleanup every object before comparing with valgrind.
at_exit { GC.start } if ENV["LD_PRELOAD"]&.include? "valgrind"

require "minitest/autorun"
require "minitest/pride"
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

Dir[File.join(__dir__, "common", "*")].sort.each { |file| require file }

require_relative "support/minitest/assert_wkt_similar"
require_relative "support/minitest/fixtures"

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
