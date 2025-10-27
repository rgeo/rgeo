# frozen_string_literal: true

require 'simplecov'

SimpleCov.command_name('Unit Tests')
SimpleCov.merge_timeout(3600)
SimpleCov.start do
  add_filter '/test/'
  add_filter '/.bundle/'
end

if ENV['CI']
  require 'simplecov_json_formatter'

  SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter
end

require 'rubygems'
require 'minitest/autorun'
require 'minitest/reporters'

if ENV['USE_BINARY_GEOS']
  require 'geos'
else
  require File.join(File.dirname(__FILE__), %w{ .. lib ffi-geos })
end

puts "Ruby version #{RUBY_VERSION}-p#{RUBY_PATCHLEVEL} - #{RbConfig::CONFIG['RUBY_INSTALL_NAME']}"
puts "ffi version #{Gem.loaded_specs['ffi'].version}" if Gem.loaded_specs['ffi']

if Geos.respond_to?(:version)
  puts "GEOS version #{Geos.version} (#{Geos::GEOS_NICE_VERSION})"
else
  puts "GEOS version #{Geos::GEOS_VERSION} (#{Geos::GEOS_NICE_VERSION})"
end

puts "ffi-geos version #{Geos::VERSION}" if defined?(Geos::VERSION)
puts "Using #{Geos::FFIGeos.geos_library_path}" if defined?(Geos::FFIGeos)
puts "Process #{$PID}"

module TestHelper
  TOLERANCE = 0.0000000000001

  EMPTY_GEOMETRY = if Geos::GEOS_NICE_VERSION >= '030800'
    'POINT EMPTY'
  else
    'GEOMETRYCOLLECTION EMPTY'
  end

  EMPTY_BLOCK = proc do
    # no-op
  end

  def self.included(base)
    base.class_eval do
      attr_reader :reader, :reader_hex, :writer
    end
  end

  def setup
    GC.start
    @reader = Geos::WktReader.new
    @reader_hex = Geos::WkbReader.new
    @writer = Geos::WktWriter.new
  end

  def read(*args, **options)
    if args[0][0] == '0'
      reader_hex.read_hex(*args, **options)
    else
      reader.read(*args, **options)
    end
  end

  def write(*args, **options)
    writer.write(*args, **options)
  end

  def geom_from_geom_or_wkt(geom_or_wkt)
    if geom_or_wkt.is_a?(String)
      read(geom_or_wkt)
    else
      geom_or_wkt
    end
  end

  def srid_copy_tester(method, expected, expected_srid, srid_policy, wkt, *args, **options)
    geom = read(wkt)
    geom.srid = 4326
    Geos.srid_copy_policy = srid_policy

    geom_b = geom.__safe_send__(method, *args, **options)

    assert_equal(4326, geom.srid)
    assert_equal(expected_srid, geom_b.srid)
    assert_equal(expected, write(geom_b))
  ensure
    Geos.srid_copy_policy = :default
  end

  {
    empty: 'to be empty',
    valid: 'to be valid',
    simple: 'to be simple',
    ring: 'to be ring',
    closed: 'to be closed',
    has_z: 'to have z dimension'
  }.each do |t, m|
    class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
      def assert_geom_#{t}(geom)
        assert(geom.#{t}?, "Expected geom #{m}")
      end

      def refute_geom_#{t}(geom)
        assert(!geom.#{t}?, "Did not expect geom #{m}")
      end
    RUBY
  end

  def assert_geom_eql_exact(geom, result, tolerance = TOLERANCE)
    assert(geom.eql_exact?(result, tolerance), "Expected geom.eql_exact? to be within #{tolerance}")
  end

  def snapped_tester(method, expected, geom, *args, **options)
    geom = geom_from_geom_or_wkt(geom)

    result = geom.__safe_send__(method, *args, **options)

    assert_equal(expected, write(result.snap_to_grid(1)))
  end

  def simple_tester(method, expected, geom, *args, **options)
    geom = geom_from_geom_or_wkt(geom)

    result = geom.__safe_send__(method, *args, **options)
    result = write(result) if result.is_a?(Geos::Geometry)

    if expected.nil?
      assert_nil(result)
    else
      assert_equal(expected, result)
    end
  end

  def simple_bang_tester(method, expected, wkt, *args, **options)
    geom = read(wkt)
    result = geom.__safe_send__(method, *args, **options)

    assert_equal(wkt, write(geom))
    assert_equal(expected, write(result))

    geom = read(wkt)
    geom.__safe_send__("#{method}!", *args, **options)

    assert_equal(expected, write(geom))
  end

  def comparison_tester(method, expected, geom_a, geom_b, *args, **options)
    geom_a = geom_from_geom_or_wkt(geom_a).normalize
    geom_b = geom_from_geom_or_wkt(geom_b).normalize

    simple_tester(method, expected, geom_a, geom_b, *args, **options)
  end

  def array_tester(method, expected, geom, *args, **options)
    geom = geom_from_geom_or_wkt(geom)
    result = geom.__safe_send__(method, *args, **options)

    case result
      when Geos::Geometry
        result = [write(result)]
      when Array
        result = result.collect do |r|
          write(r)
        end
    end

    assert_equal(expected, result)
  end

  def affine_tester(method, expected, wkt, *args, **options)
    writer.trim = true

    geom = read(wkt)
    geom.__safe_send__("#{method}!", *args, **options).snap_to_grid!(0.1)

    assert_equal(expected, write(geom))

    geom = read(wkt)
    geom_2 = geom.__safe_send__(method, *args, **options).snap_to_grid(0.1)

    assert_equal(wkt, write(geom))
    assert_equal(expected, write(geom_2, trim: true))
  end
end

class Object
  if RUBY_VERSION >= '2.7'
    def __safe_send__(method_name, *args, **kwargs)
      send(method_name, *args, **kwargs)
    end
  else
    def __safe_send__(method_name, *args, **kwargs)
      raise NoMethodError unless respond_to?(method_name)

      arity = method(method_name).arity

      if arity.zero?
        send(method_name)
      elsif arity.negative? && !kwargs.empty?
        send(method_name, *args, **kwargs)
      else
        send(method_name, *args)
      end
    end
  end
end

Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)
