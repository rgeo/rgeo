# frozen_string_literal: true

require_relative "../test_helper"

# Ensure that compatiblity table stays up to date. If this test fails
# and your diff shows a checkmark instead of a red X, thanks for adding
# that feature ! Otherwise, please take a look at your contribution.
class FactoryCompatibilityTableTest < MiniTest::Test # :nodoc:
  def test_table_ok
    unless RGeo::Geos.ffi_supported? && RGeo::Geos.capi_supported?
      skip "Factory Compatibility table can only be generated with FFI and CAPI support"
    end

    update_table_file(
      generate_markdown(
        compute_handled_methods_per_factory
      )
    )

    assert(
      system("git", "diff", "--quiet", "--", compatility_table_path),
      proc {
        require "pathname"
        relative_path = Pathname.new(compatility_table_path)
                                .relative_path_from(Pathname.new(Dir.pwd))
        "Expected #{relative_path} not to change. Please check if this " \
        "is intended and then commit changes, or fix otherwise."
      }
    )
  end

  private

  def basic_method_handled?(geometry, method_sym, description)
    if method_sym == :buffer
      geometry.public_send(method_sym, 1)
    else
      geometry.public_send(method_sym)
    end

    true
  rescue RGeo::Error::UnsupportedOperation
    false
  rescue NoMethodError => e
    debug "NoMethodError", description, e.full_message(highlight: true)
    false
  rescue StandardError => e
    debug "StandardError", description, e.full_message(highlight: true)
    false
  end

  def basic_methods
    @basic_methods ||= [
      :factory,
      :dimension,
      :geometry_type,
      :srid,
      :envelope,
      :as_text,
      :as_binary,
      :is_empty?,
      :is_simple?,
      :boundary,
      :convex_hull,
      :buffer
    ].freeze
  end

  def classify_sym(sym)
    sym.to_s.split("_").map(&:capitalize).join
  end

  def compatility_table_path
    "#{__dir__}/../../doc/Factory-Compatibility.md"
  end

  def compute_handled_methods_per_factory
    results = {}
    factories.each do |factory_key, factory|
      results[factory_key] = {}
      geometries_per_factory(factory).each do |geometry_key, geometry|
        basic_methods.each do |method_sym|
          description = "#{classify_sym(geometry_key)}##{method_sym}"
          results[factory_key][description] = basic_method_handled?(geometry, method_sym, description)
        end

        relational_methods.each do |method_sym|
          geometries_per_factory(factory).each do |other_geometry_key, other_geometry|
            description = "#{classify_sym(geometry_key)}##{method_sym}(#{classify_sym(other_geometry_key)})"
            results[factory_key][description] = relational_method_handled?(geometry, other_geometry, method_sym, description)
          end
        end
      end
    end
    results
  end

  def debug(*args)
    # puts *args
  end

  def factories
    @factories ||= {
      geos: RGeo::Geos.factory,
      geos_zm: RGeo::Geos.factory(has_z_coordinate: true, has_m_coordinate: true),
      ffi: RGeo::Geos.factory(native_interface: :ffi),
      ffi_zm: RGeo::Geos.factory(has_z_coordinate: true, has_m_coordinate: true, native_interface: :ffi),
      cartesian: RGeo::Cartesian.simple_factory,
      projection: RGeo::Geographic.simple_mercator_factory,
      spherical: RGeo::Geographic.spherical_factory
    }.freeze
  end

  def generate_markdown(handled_per_factory_per_description)
    descriptions = handled_per_factory_per_description.first.last.keys
    factories = handled_per_factory_per_description.keys

    sizes = [
      descriptions.max_by(&:size).size + 2,
      *factories.map(&:size)
    ]

    titles = ["", *factories]
    rows = descriptions.map do |description|
      [
        "`#{description}`",
        *factories.map { |factory| handled_per_factory_per_description[factory][description] ? "✅" : "❌" }
      ]
    end

    markdown = ""
    markdown += "| #{titles.zip(sizes).map { |title, size| title.to_s.center(size) } * ' | '} |\n"
    markdown += "| #{"#{'-' * (sizes.first - 1)}:"} | #{sizes[1..-1].map { |size| ":#{'-' * (size - 2)}:" } * ' | '} |\n"
    rows.each do |row|
      markdown += "| #{row.first.rjust(sizes.first)} | #{row[1..-1].zip(sizes[1..-1]).map { |cell, size| cell.center(size) } * ' | '} |\n"
    end

    markdown
  end

  def geometries_per_factory(a_factory)
    @geometries_per_factory ||= Hash.new do |hash, factory| # rubocop:disable Metrics/BlockLength
      hash[factory] = {
        point: factory.point(0, 0),
        line_string: factory.line_string(
          [factory.point(0, 0), factory.point(1, 1), factory.point(2, 2)]
        ),
        linear_ring: factory.linear_ring(
          [
            factory.point(0, 0), factory.point(0, 1), factory.point(1, 1),
            factory.point(1, 0), factory.point(0, 0)
          ]
        ),
        polygon: factory.polygon(
          factory.linear_ring(
            [
              factory.point(0, 0), factory.point(0, 1), factory.point(1, 1),
              factory.point(1, 0), factory.point(0, 0)
            ]
          )
        ),
        collection: factory.collection([]),
        multi_point: factory.multi_point([factory.point(0, 0), factory.point(1, 1)]),
        multi_line_string: factory.multi_line_string(
          [
            factory.line_string(
              [factory.point(0, 0), factory.point(1, 1), factory.point(2, 2)]
            ),
            factory.line_string(
              [factory.point(3, 3), factory.point(4, 4)]
            )
          ]
        ),
        multi_polygon: factory.multi_polygon(
          [
            factory.polygon(
              factory.linear_ring(
                [
                  factory.point(0, 0), factory.point(0, 1), factory.point(1, 1),
                  factory.point(1, 0), factory.point(0, 0)
                ]
              )
            )
          ]
        )
      }.freeze
    end
    @geometries_per_factory[a_factory]
  end

  def relational_method_handled?(geometry, other_geometry, method_sym, description)
    if method_sym == :relate?
      geometry.public_send(method_sym, other_geometry, "FT*******")
    else
      geometry.public_send(method_sym, other_geometry)
    end

    true
  rescue RGeo::Error::UnsupportedOperation
    false
  rescue NoMethodError => e
    debug "NoMethodError", description, e.full_message(highlight: true)
    false
  rescue StandardError => e
    debug "StandardError", description, e.full_message(highlight: true)
    false
  end

  def relational_methods
    @relational_methods ||= [
      :equals?,
      :eql?,
      :disjoint?,
      :intersects?,
      :touches?,
      :crosses?,
      :within?,
      :contains?,
      :overlaps?,
      :relate?
    ].freeze
  end

  def update_table_file(html)
    File.open(compatility_table_path, "r+") do |file|
      file.take_while { |line| !line.start_with?("<!-- AUTO-GENERATED") }
      file.puts html
      # Remove lines below.
      file.truncate file.pos
    end

    debug "doc/Factory-compatibility.md edited."
  end
end
