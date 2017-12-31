require "test/unit"
require "rgeo"
require "psych"
require "common/factory_tests"
require "common/geometry_collection_tests"
require "common/line_string_tests"
require "common/multi_line_string_tests"
require "common/multi_point_tests"
require "common/multi_polygon_tests"
require "common/point_tests"
require "common/polygon_tests"

begin
  require "pry-byebug"
rescue LoadError
  # ok
end
