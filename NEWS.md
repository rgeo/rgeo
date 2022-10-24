## Version 3.0 Release

RGeo version 3.0 contains a lot of bug fixes and minor improvements, as well as a few major changes to certain systems within RGeo. We'll explain those major changes in more depth here.

A comprehensive list of changes can be found in [History.md](History.md).

### Validity Handling

In previous versions of RGeo, factories would raise an error when an invalid geometry was instansiated, and users could avoid this by setting the `uses_lenient_assertions` or `uses_lenient_multipolygon_assertions` flags in their factories. For version 3 we decided to match the behavior of Geos more closely and allow invalid geometries to be instansiated and only check validity once an operation that requires validity is called on that geometry. If that geometry is invalid an error will be raised, and users can get around this by using the new `unsafe_*` variants of methods to skip the check at the risk of incorrect results.

We believe this approach has a few benefits: faster geometry creation, more consistent behavior between factory types, and more flexibility with geometries (since validation is done on a per method basis).

More details about usage and some technical details can be found in [doc/Geometry-Validity.md](doc/Geometry-Validity.md).

### Coordinate System and Coordinate Transformations

__Note: rgeo-proj4 version 4.0 will need to be used with RGeo 3.0__

In an effort to improve the interface for transforming coordinates and decoupling the `rgeo-proj4` gem from the core RGeo library, we've changed how factories are given coordinate system information. The `proj4` option has been removed from all factory creation options and the `coord_sys` option will be relied on instead.

To allow this change, we've expanded the `CS::CoordinateSystem` class and added a `CS::CoordinateTransform` class. Now any implementation of `CS::CoordinateSystem` can be passed into the `coord_sys` option and if a transformation is defined between `CoordinateSystem` instances, then factories can transform geometries between each other.

Here's a basic example taken from our tests:

```ruby
class TestAffineCoordinateSystem < RGeo::CoordSys::CS::CoordinateSystem
  def initialize(value, dimension, *optional)
    super(value, dimension, *optional)
    @value = value
  end
  attr_accessor :value

  def transform_coords(target_cs, x, y, z = nil)
    ct = TestAffineCoordinateTransform.create(self, target_cs)
    ct.transform_coords(x, y, z)
  end

  class << self
    def create(value, dimension = 2)
      new(value, dimension)
    end
  end
end

class TestAffineCoordinateTransform < RGeo::CoordSys::CS::CoordinateTransform
  def transform_coords(x, y, z = nil)
    diff = target_cs.value - source_cs.value
    coords = [x + diff, y + diff]
    coords << (z + diff) if z
    coords
  end
end

cs1 = TestAffineCoordinateSystem.create(0)
cs2 = TestAffineCoordinateSystem.create(10)

fac1 = RGeo::Cartesian.preferred_factory(coord_sys: cs1)
fac2 = RGeo::Cartesian.preferred_factory(coord_sys: cs2)

point1 = fac1.point(1, 2)
point2 = RGeo::Feature.cast(point1, factory: fac2, project: true)

p point2
#=> #<RGeo::Geos::CAPIPointImpl:0x294 "POINT (11 12)">
```

Here's a few other important transformation related changes:

* Passing a value to the `srid` option will automatically attempt to create a `CoordinateSystem` from it. Valid types are `Integer` and `String` definitions.
* A `CONFIG` object has been created for `CoordSys` that defines a `default_coord_sys_class` that factories will use to create coordinate systems from a given SRID. Note: When `rgeo-proj4` is loaded it will override this value to use the rgeo-proj4 implementation.
* Factories accept a `coord_sys_class` option if you want to define a coordinate system from an SRID and use a different implementation from `default_coord_sys_class`.
