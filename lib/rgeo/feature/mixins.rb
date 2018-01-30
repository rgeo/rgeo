# -----------------------------------------------------------------------------
#
# Mixin tracker
#
# -----------------------------------------------------------------------------

module RGeo
  module Feature
    # MixinCollection is a mechanism for adding arbitrary methods to
    # geometry objects.
    #
    # Normally, geometry objects respond to the methods defined in the
    # feature interface for that type of geometry; e.g.
    # RGeo::Feature::Geometry, RGeo::Feature::Point, etc. Some
    # implementations include additional methods specific to the
    # implementation. However, occasionally it is desirable also to
    # include custom methods allowing objects to function in different
    # contexts. To do so, provide those methods in a mixin Module, and
    # add it to an appropriate MixinCollection. A MixinCollection is
    # simply a collection of mixin Modules, connected to geometry types,
    # that are included in objects of that type.
    #
    # There is a global collection, MixinCollection::GLOBAL, which
    # manages mixins to be added to all implementations. In addition,
    # individual implementation factories may provide additional local
    # MixinCollection objects for mixins specific to objects created
    # by that factory.
    #
    # Each mixin mixin_module added to a MixinCollection is connected to a
    # specific type, which controls to which objects that mixin is added.
    # For example, a mixin connected to Point is added only to Point
    # objects. A mixin connected to GeometryCollection is added to
    # GeometryCollection objects as well as MultiPoint, MultiLineString,
    # and MultiPolygon, since those are subtypes of GeometryCollection.
    # To add a mixin to all objects, connect it to the Geometry base type.

    class MixinCollection
      # An API point controlling a particular type.

      class TypeData
        def initialize(collection, type) # :nodoc:
          @collection = collection
          @type = type
          @mixins = []
          @classes = []
          @rmixins = []
          @rclasses = []
        end

        # The feature type
        attr_reader :type

        # The MixinCollection owning this data
        attr_reader :collection

        # Add a mixin to be included in implementations of this type.

        def add(mixin_module)
          @mixins << mixin_module
          @classes.each { |k| k.class_eval { include(mixin_module) } }
          _radd(mixin_module)
        end

        # A class that implements this type should call this method to
        # get the appropriate mixins.
        # If include_ancestry is set to true, then mixins connected to
        # subtypes of this type are also added to the class.

        def include_in_class(klass, include_ancestry = false)
          (include_ancestry ? @rmixins : @mixins).each { |m| klass.class_eval { include(m) } }
          (include_ancestry ? @rclasses : @classes) << klass
          self
        end

        # An object that implements this type should call this method to
        # get the appropriate mixins.
        # If include_ancestry is set to true, then mixins connected to
        # subtypes of this type are also added to the object.

        def include_in_object(obj, include_ancestry = false)
          (include_ancestry ? @rmixins : @mixins).each { |m| obj.extend(m) }
          self
        end

        def _radd(mixin_module) # :nodoc:
          @rmixins << mixin_module
          @rclasses.each { |k| k.class_eval { include(mixin_module) } }
          @type.each_immediate_subtype { |t| @collection.for_type(t)._radd(mixin_module) }
          self
        end
      end

      # Create a new empty MixinCollection

      def initialize
        @types = {}
      end

      # Returns a TypeData for the given type.
      #
      # e.g. to add a mixin_module for point types, you can call:
      #  for_type(RGeo::Feature::Point).add(mixin_module)

      def for_type(type)
        (@types[type] ||= TypeData.new(self, type))
      end

      # Add a mixin_module connected to the given type.
      #
      # Shorthand for:
      #  for_type(type).add(mixin_module)

      def add(type, mixin_module)
        for_type(type).add(mixin_module)
      end

      # A class that implements this type should call this method to
      # get the appropriate mixins.
      #
      # Shorthand for:
      #  for_type(type).include_in_class(klass, include_ancestry)

      def include_in_class(type, klass, include_ancestry = false)
        for_type(type).include_in_class(klass, include_ancestry)
      end

      # An object that implements this type should call this method to
      # get the appropriate mixins.
      #
      # Shorthand for:
      #  for_type(type).include_in_object(obj_, include_ancestry)

      def include_in_object(type, obj, include_ancestry = false)
        for_type(type).include_in_object(obj, include_ancestry)
      end

      # The global MixinCollection. Mixins added to this collection are
      # added to all geometry objects for all implementations.

      GLOBAL = MixinCollection.new
    end
  end
end
