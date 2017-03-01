## RGeo

[![Gem Version](https://badge.fury.io/rb/rgeo.svg)](http://badge.fury.io/rb/rgeo)
[![Build Status](https://travis-ci.org/rgeo/rgeo.svg?branch=master)](https://travis-ci.org/rgeo/rgeo)

RGeo is a geospatial data library for Ruby.

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


Several optional modules are currently available:

*   Generate and interpret GeoJSON data for communication with common
    location-based web services using the **rgeo-geojson** gem.
*   Read GIS datasets from ESRI shapefiles using the **rgeo-shapefile** gem.
*   Extend ActiveRecord to handle spatial data in MySQL Spatial, SpatiaLite,
    and PostGIS using RGeo's spatial ActiveRecord adapters. These are
    available via the gems:
    *   **activerecord-postgis-adapter**
    *   **activerecord-mysql2spatial-adapter**
    *   **activerecord-spatialite-adapter**

Need help? Join the rgeo-users google group at:
http://groups.google.com/group/rgeo-users

### Dependencies

RGeo works with the following Ruby implementations:

*   Ruby 2.1.0 or later.
*   Partial support for JRuby 9.0 or later. The FFI implementation of GEOS
    is available (ffi-geos gem required) but CAPI is not.
*   See earlier versions for support for pre-2.0 ruby.

Some features also require the following:

*   GEOS 3.2 or later is highly recommended. (3.3.3 or later preferred.) Some
    functions will not be available without it. This C/C++ library may be
    available via your operating system's package manager (`sudo aptitude
    install libgeos-dev` for debian based Linux distributions, `yum install geos geos-devel` for redhat based Linux distributions), or you can
    download it from http://trac.osgeo.org/geos
*   Proj 4.7 or later is also recommended. This library is needed if you want
    to translate coordinates between geographic projections. It also may be
    available via your operating system's package manager (`sudo aptitude
    install libproj-dev` for debian based Linux distributions, `yum install proj proj-devel` for redhat based Linux distributions), or from
    http://trac.osgeo.org/proj
*   On some platforms, you should install the ffi-geos gem (version 1.2.0 or
    later recommended.) JRuby requires this gem to link properly with Geos,
    and Windows builds probably do as well.

### Installation

Install the RGeo gem:

```sh
gem install rgeo
```

Note: By default, the gem installation looks for the Proj4 library in the
following locations by default: `/usr/local`, `/usr/local/proj`,
`/usr/local/proj4`, `/opt/local`, `/opt/proj`, `/opt/proj4`, `/opt`, `/usr`, and
`/Library/Frameworks/PROJ.framework/unix`.

If Proj4 is installed in a different location, you must provide its
installation prefix directory using the "--with-proj-dir" option.

### Development and support

RDoc Documentation is available at http://rdoc.info/gems/rgeo

Source code is hosted on Github at https://github.com/rgeo/rgeo

Contributions are welcome. Fork the project on Github.

Report bugs on Github issues at https://github.com/rgeo/rgeo/issues

Support available on the rgeo-users google group at
http://groups.google.com/group/rgeo-users

### Acknowledgments

RGeo was created by [Daniel Azuma](http://www.daniel-azuma.com).
[Tee Parham](https://github.com/teeparham) is the current maintainer.

Thanks to [Pirq](http://www.pirq.com) and [Neighborland](https://neighborland.com)
for development support.

Continuous integration service provided by Travis-CI (http://travis-ci.org).

RGeo calls the GEOS library to handle most Cartesian geometric calculations,
and the Proj4 library to handle projections and coordinate transformations.
These libraries are maintained by the Open Source Geospatial Foundation; more
information is available on OSGeo's web site (http://www.osgeo.org).

JRuby support is made possible by the ffi-geos (and upcoming ffi-proj4) gems,
by J Smith (https://github.com/dark-panda).

### License

Copyright (c) Daniel Azuma, Tee Parham

https://github.com/rgeo/rgeo/blob/master/LICENSE.txt
