# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/rgeo"
require "psych"
require_relative "common/factory_tests"
require_relative "common/geometry_collection_tests"
require_relative "common/line_string_tests"
require_relative "common/multi_line_string_tests"
require_relative "common/multi_point_tests"
require_relative "common/multi_polygon_tests"
require_relative "common/point_tests"
require_relative "common/polygon_tests"

require "pry-byebug" if ENV["BYEBUG"]
