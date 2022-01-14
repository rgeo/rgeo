# Geometry Validity

**TL;DR:**

```ruby
factory = RGeo::Cartesian.preferred_factory
bowtie_polygon = factory.polygon(factory.linear_ring([factory.point(0, 4),factory.point(4, 4),factory.point(2, 6),factory.point(0, 0),factory.point(0, 4)]))
polygon =
	case bowtie_polygon.invalid_reason
	when RGeo::ImplHelper::TopologyErrors::SELF_INTERSECTION
		bowtie_polygon.make_valid
	when nil # already valid
		bowtie_polygon
	else
		bowtie_polygon.check_validity! # Make sure we raise, undefined behaviour
	end


puts polygon.area
puts "Is the polygon valid? " + (polygon.valid? ? "yes" : "no")
```

---


RGeo embraces the concept of always giving correct results, or throwing a validity
error (`RGeo::Error::InvalidGeometry`) if not possible.

Lets for instance take a bowtie shaped polygon:

```ruby
factory = RGeo::Cartesian.preferred_factory
bowtie_polygon = factory.polygon(
	factory.linear_ring(
		[
			factory.point(0, 4),
			factory.point(4, 4),
			factory.point(2, 6),
			factory.point(0, 0),
			factory.point(0, 4)
		]
	)
)
```

There is no issue with creating this polygon, or viewing its representation for
instance.

![Bowtie polygon](https://github.com/rgeo/rgeo/raw/master/doc/assets/polygon_invalid1.png)

However, its representation is invalid per specifications since it contains a
_Self-intersection_. Computing its area would give us the result of 0, definitely
not an expected result. Hence, the next code block results in a validation error:

```ruby
bowtie_polygon.area # raises: Self-intersection (RGeo::Error::InvalidGeometry)
```

Errors are mapped to GEOS errors, and are all available in the codebase:

```ruby
> constants = RGeo::ImplHelper::TopologyErrors.constants
> size = constants.map(&:size).max
> puts constants.map { "#{_1.to_s.rjust(size)}: #{RGeo::ImplHelper::TopologyErrors.const_get(_1).inspect}" }
         REPEATED_POINT: "Repeated Point"
     HOLE_OUTSIDE_SHELL: "Hole lies outside shell"
           NESTED_HOLES: "Holes are nested"
  DISCONNECTED_INTERIOR: "Interior is disconnected"
      SELF_INTERSECTION: "Self-intersection"
 RING_SELF_INTERSECTION: "Ring Self-intersection"
          NESTED_SHELLS: "Nested shells"
        DUPLICATE_RINGS: "Duplicate Rings"
         TOO_FEW_POINTS: "Too few distinct points in geometry component"
     INVALID_COORDINATE: "Invalid Coordinate"
          UNCLOSED_RING: "Ring is not closed"
TOPOLOGY_VALIDATION_ERR: "Topology Validation Error"
```

Now if you really want to compute the area of our bowtie polygon, you have some
options:

```ruby
bowtie_polygon.unsafe_area # => 0
ok_polygon = bowtie_polygon.make_valid # => #<RGeo::Geos::CAPIMultiPolygonImpl:0x244 "MULTIPOLYGON (((0.0 0.0, 0.0 4.0, 1.3333333333333333 4.0, 0.0 0.0)), ((4.0 4.0, 1.3333333333333333 4.0, 2.0 6.0, 4.0 4.0)))">
ok_polygon.area.round # => 5
```

You can also play around with validity thanks to the `RGeo::ImplHelper::ValidityCheck`
helper.
)
