# frozen_string_literal: true

require_relative "test_helper"
require "weakref"

class CartesianRTreeTest < Minitest::Test # :nodoc:
  def setup
    @factory = RGeo::Cartesian.simple_factory
    @tree = RGeo::Cartesian::RTree.new(max_entries: 4)
  end

  def test_split_queries_for_identical_collinear_and_extreme_bounds
    distributions = [Array.new(48) { [1, 1, 1, 1] },
                     Array.new(48) { |index| [index, 0, index, 0] },
                     Array.new(48) { |index| [index.even? ? -1e308 : 1e308, 0, 1e308, index] }]
    [4, 5, 16].each do |capacity|
      distributions.each do |bounds_list|
        tree = RGeo::Cartesian::RTree.new(max_entries: capacity)
        bounds_list.each_with_index { |bounds, item| tree.insert(box(@factory, bounds), item) }
        [[1, 1, 1, 1], [10, 0, 20, 0], [-1e308, -1, 1e308, 50], [100, 100, 101, 101]].each do |bounds|
          expected = bounds_list.each_index.select { |index| overlaps?(bounds_list[index], bounds) }
          assert_equal(expected, tree.query(box(@factory, bounds)).sort)
        end
        assert_equal(bounds_list.size, tree.size)
      end
    end
  end

  def test_exact_queries_respect_holes_and_keep_false_and_nil_labels
    skip "Needs GEOS." unless RGeo::Geos.capi_supported? || RGeo::Geos.ffi_supported?
    %i[capi ffi].each do |backend|
      next unless RGeo::Geos.public_send("#{backend}_supported?")

      factory = RGeo::Geos.factory(native_interface: backend)
      tree = RGeo::Cartesian::RTree.new(max_entries: 4)
      polygon = factory.parse_wkt("POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0), (2 2, 2 8, 8 8, 8 2, 2 2))")
      tree.insert(polygon, nil)
      point = factory.point(1, 1)
      tree.insert(point, false)
      assert_equal([nil], tree.query(factory.point(5, 5)))
      assert_empty(tree.query_intersections(factory.point(5, 5)))
      assert_same(polygon, tree.query_intersections(factory.point(2, 5)).fetch(nil))
      results = tree.query_intersections(point)
      assert_equal(2, results.size)
      assert_same(polygon, results.fetch(nil))
      assert_same(point, results.fetch(false))
      tree.freeze
      assert_equal(results, tree.query_intersections(point))
    end
  end

  def test_duplicate_labels_only_conflict_when_both_geometries_intersect
    skip "Needs GEOS CAPI." unless RGeo::Geos.capi_supported?
    factory = RGeo::Geos.factory(native_interface: :capi)
    tree = RGeo::Cartesian::RTree.new(max_entries: 4)
    first = factory.point(0, 0)
    second = factory.point(10, 10)
    tree.insert(first, "same".dup).insert(second, "same".dup)
    assert_same(first, tree.query_intersections(first).fetch("same"))
    assert_same(second, tree.query_intersections(second).fetch("same"))
    window = factory.parse_wkt("POLYGON ((-1 -1, 11 -1, 11 11, -1 11, -1 -1))")
    assert_raises(ArgumentError) { tree.query_intersections(window) }
    assert_equal(2, tree.size)
    assert_same(first, tree.query_intersections(first).fetch("same"))
  end

  def test_queries_and_insertions_remain_interleavable_through_splits
    [4, 5, 16].each { |capacity| assert_random_queries(@factory, capacity) }
  end

  def test_boundary_overlaps_include_edges_corners_and_degenerate_boxes
    @tree.insert(box(@factory, [0, 0, 2, 2]), :square)
    @tree.insert(@factory.point(2, 2), :point)
    @tree.insert(box(@factory, [2, -1, 2, 3]), :vertical)
    @tree.insert(box(@factory, [-1, 2, 3, 2]), :horizontal)

    assert_equal(%i[horizontal point square vertical], @tree.query(@factory.point(2, 2)).sort)
    assert_equal(%i[square vertical], @tree.query(box(@factory, [2, 0, 4, 1])).sort)
    assert_equal(%i[horizontal square], @tree.query(box(@factory, [0, 2, 1, 4])).sort)
    assert_empty(@tree.query(@factory.point(2.001, 2.001)))
  end

  def test_query_returns_envelope_candidates_not_exact_intersections
    diagonal = @factory.line_string([@factory.point(0, 0), @factory.point(10, 10)])
    @tree.insert(diagonal, :diagonal)

    assert_equal([:diagonal], @tree.query(@factory.point(0, 10)))
    other_diagonal = @factory.line_string([@factory.point(0, 10), @factory.point(1, 9)])
    @tree.insert(@factory.point(1, 10), :outside_line)
    assert_equal(%i[diagonal outside_line], @tree.query(other_diagonal).sort)
  end

  def test_duplicate_insertions_preserve_arbitrary_item_identity
    geometry = @factory.point(1, 2)
    shared = Object.new
    first = { value: 1 }
    second = { value: 1 }
    items = [shared, shared, first, second, nil, false, "mutable".dup]
    items.each { |item| assert_same(@tree, @tree.insert(geometry, item)) }

    results = @tree.query(geometry)
    assert_equal(items.size, @tree.size)
    assert_equal(items.map(&:object_id).sort, results.map(&:object_id).sort)
    results.clear
    first[:value] = 2
    assert_equal(items.size, @tree.query(geometry).size)
    assert_same(first, @tree.query(geometry).find { |item| item.equal?(first) })
  end

  def test_empty_queries_and_rejected_empty_insertions_do_not_seal_the_tree
    empties = [@factory.collection([]), @factory.multi_point([]), @factory.line_string([])]
    empties.each do |geometry|
      assert_empty(@tree.query(geometry))
      assert_empty(@tree.query_intersections(geometry))
      assert_raises(ArgumentError) { @tree.insert(geometry, :empty) }
    end
    assert_equal(0, @tree.size)

    @tree.insert(@factory.point(0, 0), :origin)
    empties.each do |geometry|
      assert_empty(@tree.query(geometry))
      assert_empty(@tree.query_intersections(geometry))
    end
    assert_equal([:origin], @tree.query(@factory.point(0, 0)))
    assert_equal(1, @tree.size)
  end

  def test_collections_of_empty_components_have_empty_bounds
    factories = [@factory]
    factories << RGeo::Geos.factory(native_interface: :capi) if RGeo::Geos.capi_supported?
    factories << RGeo::Geos.factory(native_interface: :ffi) if RGeo::Geos.ffi_supported?
    factories.each do |factory|
      tree = RGeo::Cartesian::RTree.new(max_entries: 4)
      empties = [factory.multi_line_string([factory.line_string([])]),
                 factory.collection([factory.collection([]), factory.multi_point([])])]
      empties.each do |empty|
        assert_empty(tree.query(empty))
        assert_empty(tree.query_intersections(empty))
        assert_raises(ArgumentError) { tree.insert(empty, :empty) }
      end
      assert_equal(0, tree.size)
      tree.insert(factory.point(0, 0), :origin)
      empties.each do |empty|
        assert_empty(tree.query(empty))
        assert_empty(tree.query_intersections(empty))
      end
      assert_equal([:origin], tree.query(factory.point(0, 0)))
    end
  end

  def test_nonempty_nested_collections_include_all_components
    geometry = @factory.collection([
                                     @factory.point(-5, 4),
                                     @factory.collection([@factory.multi_point([]), @factory.point(6, -3)])
                                   ])
    @tree.insert(geometry, :collection)

    assert_equal([:collection], @tree.query(@factory.point(-5, -3)))
    assert_empty(@tree.query(@factory.point(7, 4)))
  end

  def test_noncartesian_geometries_are_rejected_before_binding_a_factory
    geometry = RGeo::Geographic.spherical_factory.point(0, 0)
    assert_raises(ArgumentError) { @tree.insert(geometry, :invalid) }
    assert_raises(ArgumentError) { @tree.query(geometry) }
    @tree.insert(@factory.point(0, 0), :valid)
    assert_equal([:valid], @tree.query(@factory.point(0, 0)))
  end

  def test_empty_queries_and_failed_insertions_do_not_establish_a_factory
    other = RGeo::Cartesian.simple_factory(srid: 4326)
    assert_empty(@tree.query(other.point(0, 0)))
    assert_empty(@tree.query(other.collection([])))
    assert_raises(ArgumentError) { @tree.insert(other.collection([]), :invalid) }
    @tree.insert(@factory.point(1, 2), :valid)
    assert_equal([:valid], @tree.query(@factory.point(1, 2)))
    assert_raises(ArgumentError) { @tree.query(other.point(1, 2)) }
    assert_raises(ArgumentError) { @tree.query_intersections(other.point(1, 2)) }
  end

  def test_frozen_empty_tree_can_query_different_cartesian_factories
    @tree.freeze
    assert_empty(@tree.query(@factory.point(0, 0)))
    other = RGeo::Cartesian.simple_factory(srid: 4326)
    assert_empty(@tree.query(other.point(0, 0)))
    assert_empty(@tree.query_intersections(other.point(0, 0)))
  end

  def test_constructor_rejects_invalid_capacities
    [nil, false, "4", 4.0, -1, 0, 1, 2, 3].each do |capacity|
      assert_raises(ArgumentError) { RGeo::Cartesian::RTree.new(max_entries: capacity) }
    end
  end

  def test_insert_and_query_reject_nongeometries_and_other_factory_objects
    equivalent_factory = RGeo::Cartesian.simple_factory
    incompatible = [nil, Object.new, [0, 0], "POINT (0 0)",
                    equivalent_factory.point(0, 0), equivalent_factory.collection([]),
                    RGeo::Cartesian.simple_factory(srid: 4326).point(0, 0),
                    RGeo::Geographic.spherical_factory.point(0, 0)]
    @tree.insert(@factory.point(0, 0), :origin)
    incompatible.each do |geometry|
      assert_raises(ArgumentError) { @tree.insert(geometry, :invalid) }
      assert_raises(ArgumentError) { @tree.query(geometry) }
      assert_raises(ArgumentError) { @tree.query_intersections(geometry) }
    end
    assert_equal(1, @tree.size)
    assert_equal([:origin], @tree.query(@factory.point(0, 0)))
  end

  def test_nonfinite_xy_coordinates_are_rejected_without_changing_contents
    [Float::INFINITY, -Float::INFINITY, Float::NAN].each do |coordinate|
      [[coordinate, 0], [0, coordinate]].each do |xy|
        geometry = RGeo::Cartesian::PointImpl.new(@factory, *xy)
        assert_raises(ArgumentError) { @tree.insert(geometry, :invalid) }
        assert_raises(ArgumentError) { @tree.query(geometry) }
      end
    end
    assert_equal(0, @tree.size)
    @tree.insert(@factory.point(1, 1), :valid)
    assert_equal([:valid], @tree.query(@factory.point(1, 1)))
  end

  def test_frozen_tree_can_be_queried_but_not_inserted_into
    40.times { |index| @tree.insert(@factory.point(index, index), index) }
    @tree.freeze

    assert_equal((10..20).to_a, @tree.query(box(@factory, [10, 10, 20, 20])).sort)
    assert_empty(@tree.query(@factory.collection([])))
    assert_raises(FrozenError) { @tree.insert(@factory.point(100, 100), :new) }
    assert_equal(40, @tree.size)
    assert_empty(@tree.query(@factory.point(100, 100)))
  end

  def test_trees_cannot_be_duplicated_or_cloned
    assert_raises(TypeError) { @tree.dup }
    assert_raises(TypeError) { @tree.clone }
    @tree.insert(@factory.point(1, 1), :item).freeze
    assert_raises(TypeError) { @tree.dup }
    assert_raises(TypeError) { @tree.clone }
    assert_equal([:item], @tree.query(@factory.point(1, 1)))
  end

  def test_indexed_geometries_survive_garbage_collection
    skip "Needs GEOS CAPI." unless RGeo::Geos.capi_supported?
    @factory = RGeo::Geos.factory(native_interface: :capi)
    reference = insert_weak_geometry
    GC.start
    assert(reference.weakref_alive?)
    assert_same(reference.__getobj__, @tree.query_intersections(@factory.point(1, 2)).fetch(:retained))
  end

  def test_simple_zm_factory_ignores_z_and_m_for_overlap
    assert_xy_only(RGeo::Cartesian.simple_factory(has_z_coordinate: true, has_m_coordinate: true))
  end

  def test_capi_factories_support_interleaved_queries_and_zm
    skip "Needs GEOS CAPI." unless RGeo::Geos.capi_supported?

    assert_random_queries(RGeo::Geos.factory(native_interface: :capi))
    assert_labeled_intersections(RGeo::Geos.factory(native_interface: :capi))
    assert_xy_only(RGeo::Geos.factory(native_interface: :capi, has_z_coordinate: true, has_m_coordinate: true))
  end

  def test_ffi_factories_support_interleaved_queries_and_zm
    skip "Needs GEOS FFI." unless RGeo::Geos.ffi_supported?

    assert_random_queries(RGeo::Geos.factory(native_interface: :ffi))
    assert_labeled_intersections(RGeo::Geos.factory(native_interface: :ffi))
    assert_xy_only(RGeo::Geos.factory(native_interface: :ffi, has_z_coordinate: true, has_m_coordinate: true))
  end

  private

  def assert_labeled_intersections(factory)
    tree = RGeo::Cartesian::RTree.new(max_entries: 4)
    triangle = factory.parse_wkt("POLYGON ((0 0, 10 0, 0 10, 0 0))")
    tree.insert(triangle, :triangle)
    search = factory.point(9, 9)
    assert_equal([:triangle], tree.query(search))
    assert_empty(tree.query_intersections(search))
    points = Array.new(40) { |index| factory.point(index, index) }
    points.each_with_index { |point, index| tree.insert(point, index) }
    window = factory.parse_wkt("POLYGON ((15 15, 20 15, 20 20, 15 20, 15 15))")
    expected = (15..20).to_h { |index| [index, points[index]] }
    results = tree.query_intersections(window)
    assert_equal(expected.keys.sort, results.keys.sort)
    expected.each { |label, point| assert_same(point, results.fetch(label)) }
    tree.insert(points[15], 15)
    assert_equal(expected, tree.query_intersections(window))
    later = factory.point(16, 16)
    tree.insert(later, :late)
    assert_same(later, tree.query_intersections(window).fetch(:late))
    tree.insert(factory.point(16, 16), 15)
    assert_raises(ArgumentError) { tree.query_intersections(window) }
    assert_equal([:triangle], tree.query(factory.point(0, 10)))
  end

  def insert_weak_geometry
    geometry = @factory.point(1, 2)
    @tree.insert(geometry, :retained)
    WeakRef.new(geometry)
  end

  def box(factory, bounds)
    min_x, min_y, max_x, max_y = bounds
    factory.multi_point([factory.point(min_x, min_y), factory.point(max_x, max_y)])
  end

  def overlaps?(left, right)
    left[0] <= right[2] && left[2] >= right[0] && left[1] <= right[3] && left[3] >= right[1]
  end

  def random_bounds(random)
    x = random.rand(-50..50)
    y = random.rand(-50..50)
    [x, y, x + random.rand(0..15), y + random.rand(0..15)]
  end

  def assert_random_queries(factory, capacity = 4)
    random = Random.new(72_041)
    tree = RGeo::Cartesian::RTree.new(max_entries: capacity)
    entries = []
    assert_empty(tree.query(factory.point(0, 0)))
    96.times do |item|
      bounds = random_bounds(random)
      tree.insert(box(factory, bounds), item)
      entries << [bounds, item]
      [bounds, random_bounds(random)].each do |query_bounds|
        expected = entries.select { |entry| overlaps?(entry[0], query_bounds) }.map(&:last)
        assert_equal(expected.sort, tree.query(box(factory, query_bounds)).sort, "After insertion #{item}")
      end
    end
    assert_equal(entries.size, tree.size)
    assert_equal((0...96).to_a, tree.query(box(factory, [-100, -100, 100, 100])).sort)
    assert_empty(tree.query(box(factory, [200, 200, 300, 300])))
  end

  def assert_xy_only(factory)
    tree = RGeo::Cartesian::RTree.new(max_entries: 4)
    24.times { |index| tree.insert(factory.point(index, index, index * 100, -index * 100), index) }
    query = factory.line_string([factory.point(5, 5, -10_000, 10_000), factory.point(10, 10, -9_000, 9_000)])

    assert_equal((5..10).to_a, tree.query(query).sort)
    tree.insert(factory.point(5, 5, 99_999, 99_999), :same_xy)
    results = tree.query(factory.point(5, 5, -99_999, -99_999))
    assert_equal(2, results.size)
    assert_includes(results, 5)
    assert_includes(results, :same_xy)
    assert_empty(tree.query(factory.point(50, 50, 500, -500)))
  end
end
