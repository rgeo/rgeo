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
    # Each mixin module added to a MixinCollection is connected to a
    # specific type, which controls to which objects that mixin is added.
    # For example, a mixin connected to Point is added only to Point
    # objects. A mixin connected to GeometryCollection is added to
    # GeometryCollection objects as well as MultiPoint, MultiLineString,
    # and MultiPolygon, since those are subtypes of GeometryCollection.
    # To add a mixin to all objects, connect it to the Geometry base type.

    class MixinCollection
      # An API point controlling a particular type.

      class TypeData
        def initialize(collection_, type_) # :nodoc:
          @collection = collection_
          @type = type_
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

        def add(module_)
          @mixins << module_
          @classes.each { |k_| k_.class_eval { include(module_) } }
          _radd(module_)
        end

        # A class that implements this type should call this method to
        # get the appropriate mixins.
        # If include_ancestry_ is set to true, then mixins connected to
        # subtypes of this type are also added to the class.

        def include_in_class(klass_, include_ancestry_ = false)
          (include_ancestry_ ? @rmixins : @mixins).each { |m_| klass_.class_eval { include(m_) } }
          (include_ancestry_ ? @rclasses : @classes) << klass_
          self
        end

        # An object that implements this type should call this method to
        # get the appropriate mixins.
        # If include_ancestry_ is set to true, then mixins connected to
        # subtypes of this type are also added to the object.

        def include_in_object(obj_, include_ancestry_ = false)
          (include_ancestry_ ? @rmixins : @mixins).each { |m_| obj_.extend(m_) }
          self
        end

        def _radd(module_) # :nodoc:
          @rmixins << module_
          @rclasses.each { |k_| k_.class_eval { include(module_) } }
          @type.each_immediate_subtype { |t_| @collection.for_type(t_)._radd(module_) }
          self
        end
      end

      # Create a new empty MixinCollection

      def initialize
        @types = {}
      end

      # Returns a TypeData for the given type.
      #
      # e.g. to add a module for point types, you can call:
      #  for_type(::RGeo::Feature::Point).add(module)

      def for_type(type_)
        (@types[type_] ||= TypeData.new(self, type_))
      end

      # Add a module connected to the given type.
      #
      # Shorthand for:
      #  for_type(type_).add(module_)

      def add(type_, module_)
        for_type(type_).add(module_)
      end

      # A class that implements this type should call this method to
      # get the appropriate mixins.
      #
      # Shorthand for:
      #  for_type(type_).include_in_class(klass_, include_ancestry_)

      def include_in_class(type_, klass_, include_ancestry_ = false)
        for_type(type_).include_in_class(klass_, include_ancestry_)
      end

      # An object that implements this type should call this method to
      # get the appropriate mixins.
      #
      # Shorthand for:
      #  for_type(type_).include_in_object(obj_, include_ancestry_)

      def include_in_object(type_, obj_, include_ancestry_ = false)
        for_type(type_).include_in_object(obj_, include_ancestry_)
      end

      # The global MixinCollection. Mixins added to this collection are
      # added to all geometry objects for all implementations.

      GLOBAL = MixinCollection.new
    end
  end
end
