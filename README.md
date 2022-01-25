## RGeo

[![Gem Version](https://badge.fury.io/rb/rgeo.svg)](http://badge.fury.io/rb/rgeo)
[![CI](https://github.com/rgeo/rgeo/workflows/CI/badge.svg)](https://github.com/rgeo/rgeo/actions?query=workflow%3ACI+branch%3Amaster+event%3Apush)

RGeo is a geospatial data library for Ruby.

:warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning:

This organization is looking for maintainers, see [this issue](https://github.com/rgeo/rgeo/issues/216) for more information.

:warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning::warning:

### Summary

RGeo is a key component for writing location-aware applications in the Ruby
programming language. At its core is an implementation of the industry
standard OGC Simple Features Specification, which provides data
representations of geometric objects such as points, lines, and polygons,
along with a set of geometric analysis operations. This makes it ideal for
modeling geolocation data. It also supports a suite of optional add-on modules
that provide various geolocation-related services.

Use the core **rgeo** gem to:

*   Represent spatial and geolocation data objects such as points, lines, and
    polygons in your Ruby application.
*   Perform standard spatial analysis operations such as finding
    intersections, creating buffers, and computing lengths and areas.
*   Correctly handle spherical geometry, and compute geographic projections
    for map display and data analysis.
*   Read and write location data in the WKT and WKB representations used by
    spatial databases.


### Dependencies

RGeo works with the following Ruby implementations:

*   MRI Ruby 2.3.0 or later.
*   Partial support for JRuby 9.0 or later. The FFI implementation of GEOS
    is available (ffi-geos gem required) but CAPI is not.
*   See earlier versions for support for older ruby versions.

Some features also require the following:

*   GEOS 3.2 or later is highly recommended. (3.3.3 or later preferred.) Some
    functions will not be available without it. This C/C++ library may be
    available via your operating system's package manager (`sudo aptitude
    install libgeos-dev` for debian based Linux distributions, `yum install geos geos-devel` for redhat based Linux distributions), or you can
    download it from http://trac.osgeo.org/geos
*   On some platforms, you should install the ffi-geos gem (version 1.2.0 or
    later recommended.) JRuby requires this gem to link properly with Geos,
    and Windows builds probably do as well.

### Installation

Install the RGeo gem:

```sh
gem install rgeo
```

or include it in your Gemfile:

```ruby
gem "rgeo"
```

If you are using proj.4 extensions, include
[`rgeo-proj4`](https://github.com/rgeo/rgeo-proj4):

```ruby
gem "rgeo-proj4"
```


### Extensions

The [RGeo organization](https://github.com/rgeo) provides several gems that extend RGeo:

#### [`rgeo-proj4`](https://github.com/rgeo/rgeo-proj4)

Proj4 extensions

#### [`rgeo-geojson`](https://github.com/rgeo/rgeo-geojson)

Read and write GeoJSON

#### [`rgeo-shapefile`](https://github.com/rgeo/rgeo-shapefile)

Read ESRI shapefiles

#### [`activerecord-postgis-adapter`](https://github.com/rgeo/activerecord-postgis-adapter)

ActiveRecord connection adapter for PostGIS, based on postgresql (pg gem)

#### [`activerecord-mysql2spatial-adapter`](https://github.com/rgeo/activerecord-mysql2spatial-adapter)

ActiveRecord connection adapter for MySQL Spatial Extensions, based on mysql2

#### [`activerecord-spatialite-adapter`](https://github.com/rgeo/activerecord-spatialite-adapter)

ActiveRecord connection adapter for SpatiaLite, based on sqlite3 (*not maintained)


### Development and support

RDoc Documentation is available at https://www.rubydoc.info/gems/rgeo

Contributions are welcome. Please read the
[Contributing guidelines](https://github.com/rgeo/rgeo/blob/master/CONTRIBUTING.md).

Support may be available on the
[rgeo-users google group](https://groups.google.com/forum/#!forum/rgeo-users)
or on [Stack Overflow](https://stackoverflow.com/questions/tagged/rgeo).

### Documentation

You can see more in-depth documentation in the `doc` folder. Factories and
methods are documented inline, you should consider checking
https://rubydoc.info/gems/rgeo with the version you are currently using. Or
generate documentation locally if you're working on RGeo: `yardoc server`.

Here's the current list of available topics:

- [An introduction to Spatial Programming With RGeo](https://github.com/rgeo/rgeo/blob/master/doc/An-Introduction-to-Spatial-Programming-With-RGeo.md)
- [Enable GEOS and Proj4 on Heroku](https://github.com/rgeo/rgeo/blob/master/doc/Enable-GEOS-and-Proj4-on-Heroku.md)
- [Installing GEOS](https://github.com/rgeo/rgeo/blob/master/doc/Installing-GEOS.md)
- [Factory Compatibility](https://github.com/rgeo/rgeo/blob/master/doc/Factory-Compatibility.md)
- [Which factory should I use?](https://github.com/rgeo/rgeo/blob/master/doc/Which-factory-should-I-use.md)
- [Examples](https://github.com/rgeo/rgeo/blob/master/doc/Examples.md)
- [Who uses `rgeo`?](https://github.com/rgeo/rgeo/blob/master/doc/Gallery.md)

You can see an exhaustive and up to date list at https://rubydoc.info/gems/rgeo/index.
### Acknowledgments

[Daniel Azuma](http://www.daniel-azuma.com) created RGeo.
[Tee Parham](http://twitter.com/teeparham) is a former maintainer.
[Keith Doggett](http://www.github.com/keithdoggett), [Ulysse Buonomo](http://www.github.com/BuonOmo) are current maintainers.

Development is supported by:

- [Klaxit](https://www.github.com/klaxit)
- Goldfish Ads

RGeo calls the GEOS library to handle most Cartesian geometric calculations,
and the Proj4 library to handle projections and coordinate transformations.
These libraries are maintained by the Open Source Geospatial Foundation; more
information is available on [OSGeo's web site](http://www.osgeo.org).

JRuby support is made possible by the ffi-geos (and upcoming ffi-proj4) gems,
by [J Smith](https://github.com/dark-panda).


### License

Copyright (c) Daniel Azuma, Tee Parham

[License](https://github.com/rgeo/rgeo/blob/master/LICENSE.txt)
