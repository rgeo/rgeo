# frozen_string_literal: true

module RGeo
  module Cartesian
    # A dynamic, two-dimensional R-tree for Cartesian geometries. Inserts may
    # be interleaved with queries; neither operation builds or seals the tree.
    #
    # #query returns bounding-box candidates; #query_intersections returns an
    # exact label-to-geometry map. Bounds are snapshotted on insertion; original
    # geometries and associated items (labels) are retained by identity.
    # Indexing is XY-only. Repeated insertions remain separate entries.
    #
    # The first successful insertion establishes the factory. Subsequent inputs
    # must use that same factory object; no conversion or reprojection occurs.
    # Instances cannot be duplicated or cloned. Freezing prevents insertion but
    # still permits queries. Concurrent mutation requires external synchronization.
    class RTree
      # Returns the number of inserted entries, including duplicates.
      attr_reader :size

      # Creates an empty tree. Its factory is inferred from the first insertion.
      # +max_entries+ is the maximum number of entries per node (default 16).
      # It must be an Integer of at least 4. Non-root nodes contain at least
      # +max_entries / 2+ entries, and all leaves have the same depth.
      #
      # Raises ArgumentError for an invalid node capacity.
      def initialize(max_entries: 16)
        unless max_entries.is_a?(Integer) && max_entries >= 4
          raise ArgumentError, "max_entries must be an Integer of at least 4"
        end

        @factory = nil
        @max_entries = max_entries
        @min_entries = max_entries / 2
        @root = Node.new(true)
        @size = 0
      end

      # Inserts +item+ with a snapshot of +geometry+'s XY bounding box and
      # returns self. Any Ruby object, including nil, may be stored as an item.
      #
      # Raises ArgumentError for an empty geometry, a geometry from another
      # factory, a non-geometry, or non-finite XY bounds. Raises FrozenError
      # if the tree is frozen. A rejected insertion leaves the tree unchanged.
      def insert(geometry, item)
        raise FrozenError, "can't modify frozen #{self.class}" if frozen?

        bounds = geometry_bounds(geometry)
        raise ArgumentError, "cannot insert an empty geometry" unless bounds

        sibling = insert_entry(@root, Entry.new(bounds, geometry, item))
        if sibling
          root = Node.new(false)
          root.add(@root)
          root.add(sibling)
          @root = root
        end
        @factory ||= geometry.factory
        @size += 1
        self
      end

      # Returns an unordered Array of items whose stored bounding boxes
      # intersect +geometry+'s XY bounding box. An empty query returns [].
      # Duplicate entries yield duplicate items; item identity is preserved.
      # Queries do not change the tree or prevent subsequent insertions.
      #
      # Raises ArgumentError for a non-geometry, a geometry from another
      # factory, or non-finite XY bounds.
      def query(geometry)
        results = []
        each_candidate(geometry) { |entry| results << entry.item }
        results
      end

      # Returns a Hash mapping labels to original indexed geometries that
      # intersect +geometry+, using bounding-box pruning then +intersects?+.
      # Requires an implementation supporting that exact predicate.
      # Empty queries return {}. Repeated entries for the same label and geometry
      # collapse; distinct matching geometries with equal labels raise ArgumentError.
      # Labels use Ruby Hash equality and must remain stable while indexed.
      # Input validation is identical to #query; queries never seal the tree.
      def query_intersections(geometry)
        results = {}
        each_candidate(geometry) do |entry|
          next unless entry.geometry.intersects?(geometry)

          if results.key?(entry.item) && !results[entry.item].equal?(entry.geometry)
            raise ArgumentError, "intersecting geometries must have distinct labels"
          end
          results[entry.item] = entry.geometry
        end
        results
      end

      private

      # Mutable bounds belong only to nodes; leaf-entry bounds never change.
      class Bounds # :nodoc:
        attr_reader :min_x, :min_y, :max_x, :max_y

        def initialize(min_x, min_y, max_x, max_y)
          @min_x = min_x
          @min_y = min_y
          @max_x = max_x
          @max_y = max_y
        end

        def expand(other)
          @min_x = other.min_x if other.min_x < @min_x
          @min_y = other.min_y if other.min_y < @min_y
          @max_x = other.max_x if other.max_x > @max_x
          @max_y = other.max_y if other.max_y > @max_y
        end

        def area
          (@max_x - @min_x) * (@max_y - @min_y)
        end

        def union_area(other)
          min_x = other.min_x < @min_x ? other.min_x : @min_x
          min_y = other.min_y < @min_y ? other.min_y : @min_y
          max_x = other.max_x > @max_x ? other.max_x : @max_x
          max_y = other.max_y > @max_y ? other.max_y : @max_y
          (max_x - min_x) * (max_y - min_y)
        end

        def intersects?(other)
          @min_x <= other.max_x && @max_x >= other.min_x &&
            @min_y <= other.max_y && @max_y >= other.min_y
        end
      end

      class Node # :nodoc:
        attr_reader :leaf, :entries, :bounds

        def initialize(leaf)
          @leaf = leaf
          reset
        end

        def add(entry)
          @entries << entry
          if @bounds
            @bounds.expand(entry.bounds)
          else
            @bounds = entry.bounds.dup
          end
        end

        def reset
          @entries = []
          @bounds = nil
        end
      end

      Entry = Struct.new(:bounds, :geometry, :item)
      private_constant :Bounds, :Node, :Entry

      def initialize_copy(_other)
        raise TypeError, "#{self.class} cannot be copied"
      end

      def each_candidate(geometry)
        bounds = geometry_bounds(geometry)
        return unless bounds && @root.bounds&.intersects?(bounds)

        pending = [@root]
        until pending.empty?
          node = pending.pop
          node.entries.each do |entry|
            next unless entry.bounds.intersects?(bounds)

            if node.leaf
              yield entry
            else
              pending << entry
            end
          end
        end
      end

      def geometry_bounds(geometry)
        raise ArgumentError, "expected a Cartesian geometry" unless Feature::Geometry === geometry

        factory = geometry.factory
        compatible = if @factory
                       factory.equal?(@factory)
                     else
                       factory.is_a?(Feature::Factory::Instance) && factory.property(:is_cartesian) == true
                     end
        raise ArgumentError, "expected a Cartesian geometry from this tree's factory" unless compatible
        return if geometry.empty?

        # Native envelopes avoid materializing every vertex in Ruby. The simple
        # factory already computes envelopes with BoundingBox, so use it directly.
        source = factory.is_a?(Factory) ? geometry : geometry.envelope
        box = BoundingBox.new(factory, ignore_z: true, ignore_m: true).add_geometry(source)
        return if box.empty?

        coordinates = [box.min_x, box.min_y, box.max_x, box.max_y]
        unless coordinates.all? { |coordinate| coordinate&.finite? }
          raise ArgumentError, "geometry must have finite XY bounds"
        end

        Bounds.new(*coordinates)
      end

      # Recursive insertion returns the new sibling when a node splits. Only
      # splitting the root increases the height, keeping every leaf balanced.
      def insert_entry(node, entry)
        if node.leaf
          node.add(entry)
        else
          sibling = insert_entry(choose_subtree(node, entry.bounds), entry)
          node.bounds.expand(entry.bounds)
          node.add(sibling) if sibling
        end
        split(node) if node.entries.size > @max_entries
      end

      def choose_subtree(node, bounds)
        best = best_growth = nil
        node.entries.each do |child|
          growth = child.bounds.union_area(bounds) - child.bounds.area
          next unless prefer_node?(child, best, growth, best_growth)

          best = child
          best_growth = growth
        end
        best
      end

      # Both descent and splitting prefer less enlargement, then smaller area
      # and fewer entries. Exact ties retain the first candidate.
      def prefer_node?(candidate, current, growth, current_growth)
        return true unless current
        return growth < current_growth unless growth == current_growth

        area = candidate.bounds.area
        current_area = current.bounds.area
        return area < current_area unless area == current_area

        candidate.entries.size < current.entries.size
      end

      # Guttman's quadratic split: choose the pair wasting the most bounding
      # area, then assign the entry with the strongest enlargement preference.
      # Force remaining entries into a group when needed for minimum occupancy.
      def split(node)
        remaining = node.entries
        first, second = split_seeds(remaining)
        right_seed = remaining.delete_at(second)
        left_seed = remaining.delete_at(first)
        node.reset
        sibling = Node.new(node.leaf)
        node.add(left_seed)
        sibling.add(right_seed)

        until remaining.empty?
          if node.entries.size + remaining.size == @min_entries
            remaining.each { |entry| node.add(entry) }
            break
          elsif sibling.entries.size + remaining.size == @min_entries
            remaining.each { |entry| sibling.add(entry) }
            break
          end

          index, left_growth, right_growth = split_next(remaining, node.bounds, sibling.bounds)
          entry = remaining.delete_at(index)
          target = prefer_node?(sibling, node, right_growth, left_growth) ? sibling : node
          target.add(entry)
        end
        sibling
      end

      def split_seeds(entries)
        first = 0
        second = 1
        greatest_waste = nil
        entries.each_with_index do |entry, index|
          area = entry.bounds.area
          ((index + 1)...entries.size).each do |other_index|
            other = entries[other_index].bounds
            waste = entry.bounds.union_area(other) - area - other.area
            next unless greatest_waste.nil? || waste > greatest_waste

            greatest_waste = waste
            first = index
            second = other_index
          end
        end
        [first, second]
      end

      def split_next(entries, left, right)
        left_area = left.area
        right_area = right.area
        best_index = 0
        best_left = best_right = greatest_difference = nil
        entries.each_with_index do |entry, index|
          left_growth = left.union_area(entry.bounds) - left_area
          right_growth = right.union_area(entry.bounds) - right_area
          difference = (left_growth - right_growth).abs
          next unless greatest_difference.nil? || difference > greatest_difference

          greatest_difference = difference
          best_index = index
          best_left = left_growth
          best_right = right_growth
        end
        [best_index, best_left, best_right]
      end
    end
  end
end
