# frozen_string_literal: true

at_exit do
  File.open(ENV["RUBY_MEMCHECK_LOADED_FEATURES_FILE"], "w") do |f|
    f.write($LOADED_FEATURES.join("\n"))
  end

  # We need to remove the @_memoized instance variable from Minitest::Spec
  # objects because it holds a hash that contains memoized objects in `let`
  # blocks, this can contain objects that will be reported as a memory leak.
  if defined?(Minitest::Spec)
    require "objspace"

    ObjectSpace.each_object(Minitest::Spec) do |obj|
      if obj.instance_variable_defined?(:@_memoized)
        obj.remove_instance_variable(:@_memoized)
      end
    end
  end

  GC.start
end
