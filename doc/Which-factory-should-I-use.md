# Which factory should I use?

## What is a factory?

When doing geometric computations, you need to consider not only the shapes that you're working with but also what domain the geometries exist in. For example, you could be working on an infinite 2D or 3D cartesian space, a spherical model of the earth, or a projection of the earth onto a bounded plane. For geometries to be compared with each other, they have to exist in the same domain, so they must all be created with the same "configuration." RGeo uses the [Factory method design pattern][factory_pattern-wikipedia] ([ELI5][factory_pattern-reddit]) to abstract this complexity. Using this OOP pattern, you can just choose the factory you want once, and every object created from it will have the same configuration. For example, if you're coding a standard Rails application, you could define a global factory like this:

```ruby
# config/initializers/rgeo.rb
RGEO_FACTORY = RGeo::Cartesian.factory

# Somewhere in the code
some_polygon.contains?(RGEO_FACTORY.point(42.0, 42.0))
```

And every geometry created with it will be in the same coordinate system.

## What factories are available?

<!-- NOTE: This list was initiated for RGeo 2.2.0 with the following ruby code

```ruby
require "rgeo"

factories = RGeo.constants.flat_map { |c|
  c = RGeo.const_get(c)
  c.methods.grep(/factory$/).map { |f| { mod: c, met: f } }
}.map { |mod:,met:|
  source, line = mod.method(met).source_location
  source = source[%r(lib/rgeo/.*)]
  invocation = "#{mod}.#{met}"
  link = "https://github.com/rgeo/rgeo/blob/v2.2.0/#{source}#L#{line}"

  "| [#{invocation}](#{link}) | TODO: usage summary |"
}

puts [
  "| Factory | Usage |",
  "| ------- | ----- |",
  *factories
]
```

-->

| Factory | Description |
| ------- | ----- |
| [`RGeo::Geographic.spherical_factory`](https://github.com/rgeo/rgeo/blob/v2.2.0/lib/rgeo/geographic/interface.rb#L117) | Models the Earth as a sphere. Coordinates are accepted as latitudes and longitudes. |
| [`RGeo::Geographic.simple_mercator_factory`](https://github.com/rgeo/rgeo/blob/v2.2.0/lib/rgeo/geographic/interface.rb#L215) | Uses a [mercator projection][web-mercator-proj] as the underlying domain, but accepts geometries described by latitudes and longitudes for simplicity.  |
| [`RGeo::Geographic.projected_factory`](https://github.com/rgeo/rgeo/blob/v2.2.0/lib/rgeo/geographic/interface.rb#L348) | Similar to the `simple_mercator_factory`, except that the underlying projection can be specified with a [coordinate reference system WKT string][proj-wkt]. |
| [`RGeo::Geos.factory`](https://github.com/rgeo/rgeo/blob/v2.2.0/lib/rgeo/geos/interface.rb#L178) | Cartesian coordinate system, using either the GEOS C API or FFI. |
| [`RGeo::Cartesian.simple_factory`](https://github.com/rgeo/rgeo/blob/v2.2.0/lib/rgeo/cartesian/interface.rb#L107) | A pure Ruby cartesian factory implementation. Lacking a lot of features that a Geos factory has. |
| [`RGeo::Cartesian.preferred_factory`](https://github.com/rgeo/rgeo/blob/v2.2.0/lib/rgeo/cartesian/interface.rb#L29) | Tries to use `RGeo::Geos.factory`, but defaults to `RGeo::Cartesian.simple_factory`. |
| [`RGeo::Cartesian.factory`](https://github.com/rgeo/rgeo/blob/v2.2.0/lib/rgeo/cartesian/interface.rb#L29) | An alias for `RGeo::Cartesian.preferred_factory` |

If you don't know the difference between those, then you should use `RGeo::Cartesian.preferred_factory`, and if you care about performance or you want to do heavy computations, you should [install GEOS](https://github.com/rgeo/rgeo/wiki/Installing-GEOS).

## How do I use a factory?

<!-- TODO: may be redundant with previous question -->
Once you've selected what type of factory you want from the list above, you need to define the other properties of your factory. Here's a list of some:

`srid` -- Spatial Reference Identifier used to define what projection the factory is using. Note: just setting this will not automatically project data to this coordinate system. It is just an identifier.

`has_z_coordinate` -- Gives all geometries created with the factory a Z-coordinate.

`has_m_coordinate` -- Gives all geometries created with the factory an M-coordinate.

`uses_lenient_assertions`: Specify that invalid geometries may be instantiated if set to `true`.

See the documentation for a complete list for each factory.

Now you can create your factory:

```rb
require 'rgeo'

# Create a 3D Cartesian factory that allows for invalid geometries to be created. Specify that geometries exist in a mercator project (srid: 3857).
factory = RGeo::Cartesian.preferred_factory(uses_lenient_assertions: true, has_z_coordinate: true, srid: 3857)
```

To create geometries, using the factory design pattern is quite straightforward: just do never instantiate your objects with `new`, but rather use your factory to create an object.

```rb
pt1 = factory.point(1, 1, 1)
pt2 = factory.point(1, 2, 1)
pt3 = factory.point(2, 2, 1)
pt4 = factory.point(2, 1, 1)

ring = factory.linear_ring([pt1, pt2, pt3, pt4, pt1])
polygon = factory.polygon(ring)

p polygon.area
# => 1.0
```

## I'm working with lat/lon data. Should I just use `spherical_factory`?

This question is not as straightforward as it seems. While it can be tempting to use the `spherical_factory` for any form of geographic data, it is not always appropriate. The required operations and geometry types dictate whether you should use a `spherical_factory` or a cartesian factory in a [projected coordinate system][projected-coordinate-systems].

The benefits of a spherical representation are that distances between points will be correct over long distances and effects from the curvature of the Earth are accounted for. The disadvantage is that computations on a spherical surface are much harder than on a planar surface because lines are represented as arcs.

Here's an example showing the shortest path from Seattle to London on a spherical model and on a mercator projection.

![geographic](https://user-images.githubusercontent.com/12189611/104756125-63870200-5729-11eb-8730-d6795b765fe8.png)
![cartesian](https://user-images.githubusercontent.com/12189611/104756230-8b766580-5729-11eb-8f97-2aa5eb70d482.png)

As you can see, they don't follow the same path. We can also check their distances in RGeo:

```rb
require 'rgeo'
coords = [[-122.33, 47.606],[0.0, 51.5]]

geo_fac = RGeo::Geographic.spherical_factory
merc_fac = RGeo::Geographic.simple_mercator_factory

geo_ls = geo_fac.line_string([geo_fac.point(coords[0][0], coords[0][1]), geo_fac.point(coords[1][0], coords[1][1])])
merc_ls = merc_fac.line_string([merc_fac.point(coords[0][0], coords[0][1]), merc_fac.point(coords[1][0], coords[1][1])])

p (merc_ls.length - geo_ls.length)/1000
#=> 5919.95321890382
```

There is a difference of about 6,000km in the length of the line string which is obviously problematic if that needs to be accurate in your application. Over short distances, this problem is not as much of an issue. I generally consider "short" distances a few hundred kilometers, but this depends on how accurate you need your data to be.

Generally, I will use a spherical model when:
- I'm working with simple geometries like `points`, `line_strings`, simple `polygons`.
- The computations I'm performing are simple `distance`, `area`. Not complex relationships like `intersection`, `touches?`, etc.
- Geometries I'm comparing are far apart. Note: this doesn't mean you're working with a large area, but that the comparisons you're doing take place over a large area.
  - Cross-continental flights happen over a large distance and the comparison is from the start and end points which are far away.
  - Examining the relationships between postal codes in a country, while over a large distance, do not happen far away since each postal code is being compared to its neighbors and each postal code is relatively small.


I will use a projected coordinate system when:
- I'm working with complex geometries like `multi_polygons`.
- The computations are complex.
- The things being compared are not far away from each other.
- Point in polygon and Geocoding applications.
- Working in a small region.


[factory_pattern-wikipedia]: https://en.wikipedia.org/wiki/Factory_method_pattern
[factory_pattern-reddit]: https://www.reddit.com/r/explainlikeimfive/comments/lxbm2/eli5_factory_method_design_pattern/
[web-mercator-proj]: https://en.wikipedia.org/wiki/Web_Mercator_projection
[proj-wkt]: https://en.wikipedia.org/wiki/Well-known_text_representation_of_coordinate_reference_systems
[projected-coordinate-systems]: http://www.geo.hunter.cuny.edu/~jochen/gtech201/lectures/lec6concepts/06%20-%20Projected%20coordinate%20systems.html
