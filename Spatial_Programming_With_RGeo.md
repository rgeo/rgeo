# An Introduction to Spatial Programming With RGeo

*   by Daniel Azuma
*   version 0.4 (23 May 2011)


## Introduction

### About This Document

One of the most important current trends in the high-tech industry is the rise
of spatial and location-based technologies. Once the exclusive domain of
complex GIS systems, these technologies are now increasingly available in
small applications, websites, and enterprises. This document provides a brief
overview of the concepts, techniques, and tools for implementing
location-aware application features, focusing on the Ruby programming language
and an open-source technology stack.

The contents of this document are as follows.

*   Section 1 is a short introduction to geospatial technology, including a
    survey of the common tools and libraries available.
*   Section 2 introduces the standard spatial data types such as points,
    lines, and polygons used by most geospatial applications.
*   Section 3 summarizes the standard spatial operations that are defined on
    those data types.
*   Section 4 discusses coordinate systems and geographic projections, and why
    it is important to get them right.
*   Section 5 covers the most common open source spatial databases.
*   Section 6 briefly covers interoperability with location services and other
    externally-sourced geospatial data.


Geographic information systems (GIS) is a broad and highly sophisticated
field, and this introduction will only scratch the surface of the current
state of the art. The goal is not to be comprehensive, but to summarize the
important elements, and reference outside resources for readers seeking more
detailed information.

### About The Author

[Daniel Azuma](http://www.daniel-azuma.com/) is the chief software architect
and a co-founder of [GeoPage, Inc.](http://www.geopage.com/), a Seattle-based
startup developing location-aware consumer applications. Daniel has been
working with Ruby on Rails since 2006, and has a background in computer
graphics and visualization. He is also the author of RGeo, the advanced
spatial data library for Ruby covered in this document.

## 1. Space: The Next Frontier

### 1.1. Why Spatial Programming?

By 2010, location had established itself as one of the hottest emerging
technological trends. In January, a Juniper Research report predicted that
mobile location services alone could drive revenues of nearly $13 billion by
2014 (see [TechCrunch
article](http://techcrunch.com/2010/02/23/location-based-services-revenue/)),
while location dominated new feature offerings from a myriad of startups as
well as from giants such as Facebook and Twitter. Although the underlying
disciplines of computer-assisted cartography and geographic information
systems (GIS) have been around for several decades, they have broken into
mainstream consumer technology only very recently. This has largely been due
to a few key developments, notably, the success of online mapping applications
beginning with Google Maps, and the ubiquity of mobile GPS devices especially
in mobile phones.

Despite this growing interest, location-aware applications remain difficult to
develop because the concepts and techniques involved are only beginning to
make their way into the mainstream developer consciousness and tools. The
primary purpose of this document is to cover the basics that a Ruby or Ruby On
Rails developer needs to know when developing with location data, and to
introduce the tools and resources that are available.

### 1.2. The Emerging Spatial Ecosystem

Fortunately, a number of software libraries and organizations now exist to
promote and assist developing spatial applications. Here we will survey some
of the popular and emerging open software systems available for integration
into your location-aware application.

Visualization tools have advanced considerably in recent years. Mapping
services such as [Google Maps](http://maps.google.com/) and [Bing
Maps](http://www.bing.com/maps/) now have extensive API support for developing
mapping applications. An open mapping service,
[OpenStreetMap](http://www.openstreetmap.org/), has also been launched and is
gaining momentum. In addition, tools which let you serve your own map data,
such as [OpenLayers](http://openlayers.org/) and
[PolyMaps](http://polymaps.org/), have also appeared.

Most major relational databases now support spatial extensions. The
[MySQL](http://mysql.com/) database provides basic spatial column support out
of the box. Third-party add-on libraries exist for
[Sqlite3](http://www.sqlite.org/) and [PostgreSQL](http://www.postgresql.org/)
in the form of [SpatiaLite](http://www.gaia-gis.it/spatialite/) and
[PostGIS](http://www.postgis.org/), respectively. Commercial databases such as
Oracle and Microsoft SQL Server also provide facilities for storing and
querying spatial data. Spatial features are also appearing in non-relational
data stores. [MongoDB](http://www.mongodb.org/) recently introduced geospatial
indexing, [Solr](http://lucene.apache.org/solr/) supports spatial queries in
the latest release of its Lucene-based search engine, and
[Sphinx](http://sphinxsearch.com/) also provides limited spatial search
capabilities.

A variety of data services have also appeared. Geocoding, the process
approximating a latitude/longitude coordinate from a street address, is now
offered by most major mapping service vendors such as
[Google](http://code.google.com/apis/maps/documentation/geocoding/),
[Microsoft](http://www.microsoft.com/maps/developers/), and
[Yahoo](http://developer.yahoo.com/geo/placefinder/). Place databases with
geocoded business and major location listings are now also available from a
variety of vendors. Several services, notably
[SimpleGeo](http://www.simplegeo.com/), have recently appeared for cloud-based
storage and querying of custom location data.

Integrating these existing services in a web application is often a challenge,
but a few integration libraries and frameworks do exist.
[GeoDjango](http://geodjango.org/) is an add-on for the Python-based Django
web framework for building location-based applications.
[RGeo](http://github.com/rgeo/rgeo) is a suite of libraries for Ruby that can
perform the same function for Ruby on Rails.

Perhaps most important of all, however, are the organizations that have
appeared to support the development of geospatial standards and software. The
[Open Geospatial Consortium](http://www.opengeospatial.org/) (OGC) is an
international consortium of companies, government agencies, and other
organizations that promote interoperability by developing open standards and
interfaces for geospatial software systems. Many of the concepts, data types,
and operations described in this document were standardized by the OGC. The
[Open Source Geospatial Foundation](http://www.osgeo.org/) develops and
supports a variety of open source geospatial software, including PostGIS,
GEOS, Proj, and others we will cover in this document. The [OGP Geomatics
Committee](http://www.epsg.org/) (formerly EPSG, the European Petroleum Survey
Group) is part of an industry association maintaining the *de facto* standard
EPSG geodetic data set, a set of coordinate systems and transformations used
internationally to describe global position. These and other organizations
form the backbone of geospatial technology, and most geospatial applications
will interact at least indirectly with their services.

### 1.3. Ruby Libraries and RGeo

Ruby developers have had access to a fair number of spatial tools, primarily
integration libraries for external services.
[Geokit](http://geokit.rubyforge.org/) and
[Geocoder](http://www.rubygeocoder.com/) provide a common interfaces for
querying geocoding services, and basic ActiveRecord extensions for simple
spatial queries. [YM4R](http://ym4r.rubyforge.org/) provides a simple
interface for integrating the Google and Yahoo map visualization tools in a
Ruby application. Finally, [GeoRuby](http://georuby.rubyforge.org/) provides
classes for basic spatial data types such as points, lines, and polygons, and
the add-on library
[spatial_adapter](http://github.com/fragility/spatial_adapter) hacks a few of
the popular ActiveRecord database adapters to support spatial columns in the
database.

In this document, we will cover [RGeo](http://github.com/rgeo/rgeo), a recent
spatial data library for Ruby that provides a complete and robust
implementation of the standard OGC spatial data types and operations. It
covers some of the same functionality as GeoRuby and spatial_adapter. However,
where GeoRuby implements only a minimal subset of the OGC feature interfaces,
RGeo supports the entire specification, as well as providing many features and
extensions not available with the older libraries.

RGeo comprises several libraries, distributed as gems: a core library, and a
suite of optional add-on modules. The core library, distributed as the
[rgeo](http://github.com/rgeo/rgeo) gem, includes the spatial data
implementation itself. Currently available add-on modules include
[rgeo-geojson](http://github.com/rgeo/rgeo-geojson), which reads and writes
the [GeoJSON](http://www.geojson.org/) format, and
[rgeo-shapefile](http://github.com/rgeo/rgeo-shapefile), which reads ESRI
shapefiles. A number of ActiveRecord adapters also utilize RGeo to communicate
with spatial databases; these include
[mysqlspatial](http://github.com/rgeo/activerecord-mysqlspatial-adapter),
[mysql2spatial](http://github.com/rgeo/activerecord-mysql2spatial-adapter),
[spatialite](http://github.com/rgeo/activerecord-spatialite-adapter), and
[postgis](http://github.com/rgeo/activerecord-postgis-adapter).

## 2. Spatial Data Types

This section will cover the standard types of spatial data used in geospatial
applications.

### 2.1. The Simple Features Specification

The Open Geospatial Consortium (OGC) defines and publishes a specification
entitled "[Geographic information -- Simple feature
access](http://www.opengeospatial.org/standards/sfa)", which defines, among
other things, a set of spatial data types and operations that can be done on
them. This standard, which we will refer to as the Simple Features
Specification (SFS), defines the core types and interfaces used by most
spatial applications and databases. Although more recent versions of the spec
are now available, most current implementations, including RGeo, follow
version 1.1 of the SFS, and this is the specification we will cover here.

A "feature" in the SFS is a geometric object in 2 or 3 dimensional space.
These objects can be points, lines, curves, surfaces, and polygons-- in
general, most 0, 1, or 2 dimensional objects are supported. Each of these
objects is identified by coordinates (X, Y, and sometimes Z), and has an
object-oriented interface associated with it, defining a set of operations
that can be performed. In RGeo, these interfaces exist as modules in the
RGeo::Feature namespace.

We will quickly cover the types of geometric objects supported, and then
discuss how to use RGeo to create and manipulate spatial data as Ruby objects.

### 2.2. Coordinates

Geometric objects generally exist in a two-dimensional domain (such as a plane
or a globe) identified by X and Y coordinates. These coordinates could be
screen coordinates, as on a map displayed on a computer screen, they could be
longitude/latitude coordinates, where X represents longitude and Y represents
latitude, or they could be in a different coordinate system altogether.

Strictly speaking, version 1.1 of the SFS supports only two dimensions.
However, many implementations can represent up to four coordinates, including
an optional Z and M coordinate. Z, when present, is generally used for a third
dimension of location; for example, it could represent altitude, a distance
above or below the surface of the earth. M, when present, is used to represent
a "measure", a scalar value that could change across an object. The measure
could, for example, represent temperature, population density, or some other
function of location. Most current implementations, though they can represent
and store Z and M, will not actually perform any analysis with those
coordinates; they act merely as additional data fields.

### 2.3. Point

An SFS "Point" is a single 0-dimensional point in space. Points are typically
used in location applications to represent a single location, displayed as a
map marker. You can retrieve the coordinates X and Y (and optionally Z and M)
from a point object.

### 2.4. LineString

An SFS "LineString" is a set of one or more connected line segments
representing a single continuous, piecewise linear path. It could, for
example, represent the path of a single street, the full driving directions
from one point to another, or the path of a waterway. It is defined by
connecting a series of points in order with line segments, and you can
retrieve those points from the LineString object.

LineString itself has two subclases, Line and LinearRing. Line is restricted
to a single line segment (i.e. two points). LinearRing is a "closed"
LineString, in which the two endpoints are coincident.

(LineString is actually a subclass of the more general abstract class "Curve",
which need not be piecewise linear. However, Curve is not by itself
instantiable, and the current SFS version does not actually specify another
type of instantiable Curve that is not a LineString.)

### 2.5. Polygon

An SFS "Polygon" is a connected region of two-dimensional space. Its outer
boundary is defined as a LinearRing, so it can have any number of straight
"sides". Polygons can also optionally contain "holes", represented by inner
boundaries which are also LinearRings. You can retrieve the outer and inner
boundaries from a Polygon object as LinearRing objects. Polygons are ideal for
representing single plots of land such as property boundaries, or larger
regions of the earth's surface such as city, state, or national boundaries,
time zones, lakes, and so forth, as long as they are contiguous.

(Polygon is also a subclass of a more general abstract class, this one called
"Surface". In general, the boundaries of a Surface need not be piecewise
linear. However, Surface is not by itself instantiable, and the current SFS
version does not actually specify another type of instantiable Surface other
than Polygon.)

### 2.6. MultiPoint

An SFS "MultiPoint" is a collection of zero or more Point objects. You might,
for example, represent the locations of all your favorite restaurants as a
MultiPoint.

### 2.7. MultiLineString

An SFS "MultiLineString" is a collection of zero or more LineString objects.
It might be used, for example, to represent all the currently "congested"
sections of a city's freeways during rush hour. It could even, in principle,
represent the entire street map of a city, though such a data structure might
be too large to be practical.

(MultiLineString is a subclass of the non-instantiable abstract class
MultiCurve.)

### 2.8. MultiPolygon

An SFS "MultiPolygon" is a collection of zero or more Polygon objects. It also
has a few additional restrictions, notably that the constituent polygons must
all be disjoint and cannot overlap. MultiPolygons are used to represent a
region which could have multiple unconnected parts.

(MultiPolygon is a subclass of the non-instantiable abstract class
MultiSurface.)

### 2.9. Geometry and GeometryCollection

The various geometric data types described above are arranged in a class
hierarchy. The base class of this hierarchy is Geometry. The MultiPoint,
MultiLineString, and MultiPolygon types (or more precisely, MultiPoint,
MultiCurve, and MultiSurface) are subclasses of a more general data type
called GeometryCollection. GeometryCollection can also be instantiated by
itself. It represents a general collection of other geometry objects, each of
which can be any type.

For complete details on the geometry class hierarchy, download the actual
[Simple Features Specification](http://www.opengeospatial.org/standards/sfa).
I recommend downloading version 1.1, because the newer versions (1.2 and
later) describe additional types and features that are not commonly available
in current implementations. That additional information may be confusing.

### 2.10. RGeo Geometry Factories

The data types we have covered here are actually merely interface
specifications. RGeo provides several different concrete implementations of
these data type interfaces, intended for different use cases. For example, the
RGeo::Geos implementation is RGeo's main implementation which provides every
data type and every operation defined by the SFS. However, that implementation
requires a third-party C library, GEOS, to be installed. In cases where that
library is not available, RGeo provides an alternative, the Simple Cartesian
implementation, which is a pure Ruby implementation that provides every data
type but does not implement some of the more advanced geometric operations.
RGeo also provides further implementations that are designed specifically to
work with geographic (longitude/latitude) coordinates, and different
projections and ways of performing calculations on the earth's surface. These
different implementations are described in more detail in the section on
Coordinate Systems and Projections.

Each concrete implementation is represented in RGeo by a factory. A factory is
an object that represents the coordinate system and other settings for that
implementation. It also provides methods for creating actual geometric objects
for that implementation, as defined in the RGeo::Feature::Factory interface.
For example:

    factory = get_my_factory()
    point1 = factory.point(1, 2)
    point2 = factory.point(3, -1)
    line = factory.line_string([point1, point2])

The most common factory used by RGeo is the "preferred Cartesian" factory.
This factory uses a flat (Cartesian) coordinate system, and is implemented by
GEOS (if available) or using the pure Ruby alternative if not. It can be
retrieved by calling:

    factory = RGeo::Cartesian.preferred_factory()

Another common factory you might want to use is the "simple Mercator" factory.
This is a geographic factory intended for simple location-based applications
that use Google or Bing Maps as a visualization tool. Its coordinate system is
longitude-latitude, but it also has a built-in facility for converting those
coordinates to the flat "tiling" coordinate system used by the map. You can
retrieve it by calling:

    factory = RGeo::Geographic.simple_mercator_factory()

In many cases, these factory creation methods take additional optional
arguments that enable various features. For example, the preferred Cartesian
factory, by default, uses only X and Y coordinates. You can activate Z and/or
M coordinates by passing an appropriate argument, e.g.:

    factory = RGeo::Cartesian.preferred_factory(:has_z_coordinate => true)
    factory.property(:has_z_coordinate)  # returns true
    factory.property(:has_m_coordinate)  # returns false
    point = factory.point(1, 2, 3)       # this point has a Z coordinate

Note that, in many cases, the factory class itself as well as the actual
implementation classes for the geometric objects, are opaque in RGeo. You
should refer to the appropriate interfaces in the RGeo::Feature namespace for
the methods you can call.

## 3. Spatial Operations

In addition to representing geometric data, the SFS interfaces define a suite
of basic operations on this data. These operations are available in many
forms, depending on the type of software system. Spatial databases such as
PostGIS define these as SQL functions that can be used to write queries.
RGeo's goal is to make geometric objects available to Ruby programs, and so
these operations are exposed as methods on the geometric Ruby objects.

These operations cover a wide range of functionality, and some involve
difficult problems of computational geometry, especially over a non-flat
coordinate system such as geographic coordinates. RGeo provides a complete
implementation for flat Cartesian coordinates that utilizes the
[GEOS](http://trac.osgeo.org/geos/) library internally. However, some of
RGeo's other implementations provide only a subset of these operations. If you
use the PostGIS database, you will find a similar situation. The "geometry"
data types actually use GEOS internally to perform geometric computations, and
pretty much all functions are available. However, the "geography" data type,
which operates on a curved coordinate system, implements only a handful of the
defined functions.

### 3.1. Basic Properties

Most geometry types have a "degenerate" form representing no geometry. For
example, a GeometryCollection may contain no items, or a LineString may
contain no points. This state is indicated by the `Geometry#empty?` method.
In RGeo, any geometry type except Point may be empty.

    factory = RGeo::Cartesian.preferred_factory
    factory.point(1, 2).empty?     # returns false
    factory.collection([]).empty?  # returns true

A second common property of geometry objects is "simplicity", which basically
means the geometry doesn't intersect or repeat itself. For example, a
LineString that intersects itself is not simple, nor is a MultiPoint that
contains the same point more than once. Sometimes, a geometric analysis
algorithm will have simplicity as a precondition. This property is indicated
by the `Geometry#simple?` method.

    factory = RGeo::Cartesian.preferred_factory
    p00 = factory.point(0, 0)
    p01 = factory.point(0, 1)
    p11 = factory.point(1, 1)
    p10 = factory.point(1, 0)
    zigzag_line = factory.line_string([p00, p10, p01, p11])
    zigzag_line.simple?         # returns true
    self_crossing_line = factory.line_string([p00, p11, p01, p10])
    self_crossing_line.simple?  # returns false

All geometry objects also contain a "spatial reference ID", returned by the
`Geometry#srid` method. This is an external ID reference indicating the
"spatial reference system", or coordinate system in use by the geometry. See
the section on Coordinate Systems and Projections for further discussion.

### 3.2. Relational Operations

The SFS specifies a suite of comparison operations that test geometric objects
for such relational predicates as equality, overlap, containment, and so
forth. In RGeo, these operations are implemented by methods that return
booleans. e.g.

    if polygon1.overlaps?(polygon2)
      # do something
    end

I do not have space here to describe the different comparison operations in
detail. See the SFS for the precise defintions. However, I do want to point
out one particular feature of RGeo related to equality checking. The Ruby
language has a number of different methods for testing different "forms" of
equality. For example:

    1 == 1        # => true
    1 == 1.0      # => true  (because the values are the same)
    1.eql?(1)     # => true
    1.eql?(1.0)   # => false  (because the classes are different)
    a = "foo"
    b = "foo"
    a == b        # => true
    a.eql?(b)     # => true
    a.equal?(b)  # => false  (because they are different objects)
    a.equal?(a)  # => true

In general, Ruby has three forms of equality: value equality (tested by the
`==` operator), object equality (tested by the `eql?` method), and object
identity (tested by the `equal?` method).

Similarly, RGeo's equality checking comes in several forms: geometric
equality, representational equality, and object identity. Geometric equality
is tested by the SFS method `equals?`, as well as the `==` operator. This type
of equality indicates two objects that may be different representations of the
same geometry, for example, a LineString and its reverse, or a Point and a
MultiPoint that contains only that same point. Representational equality,
tested by `eql?`, means the same representation but possibly distinct objects.
Object identity, tested by `equal?`, represents the same object, as with other
Ruby types.

    p1 = factory.point(1, 1)
    p2 = factory.point(1, 1)
    mp = factory.multi_point([p1])
    p1 == p2        # => true
    p1.equals?(mp)   # => true
    p1 == mp        # => true
    p1.eql?(mp)     # => false
    p1.eql?(p2)     # => true
    p1.equal?(p2)  # => false
    p1.equal?(p1)  # => true

### 3.3. Binary Spatial Operations

The SFS also provides several operations that take two geometries and yield a
third. For example, you can calculate the intersection, union, or difference
between two geometries. In addition to the methods specified by the SFS
interfaces, RGeo provides operators for some of these calculations.

    p1 = factory.point(1, 1)
    p2 = factory.point(2, 2)
    union = p1.union(p2)      # or p1 + p2
    union.geometry_type       # returns RGeo::Feature::MultiPoint
    union.num_geometries      # returns 2
    diff = p1.difference(p2)  # or p1 - p2
    diff.empty?            # returns true

### 3.4. Unary Spatial Operations

Methods are provided to compute the boundary of an object, the envelope (i.e.
the bounding box), and the convex hull. In addition, there is a "buffer"
method that attempts to return a polygon approximating the area within a given
distance from the object. Note that, because the SFS does not yet define any
geometric types with curved edges, most buffers will be polygonal
approximations.

### 3.5. Size and Distance

Several size and distance calculations are available. You can compute the
distance between two geometric objects, the length of a LineString, or the
area of a Polygon. Note that there will be some cases when these computations
don't make much sense due to the coordinate system.

    p00 = factory.point(0, 0)
    p20 = factory.point(2, 0)
    p11 = factory.point(1, 1)
    p00.distance(p11)              # returns 1.41421356...
    line = factory.line(p00, p20)
    line.length                    # returns 2
    line.distance(p11)             # returns 1
    ring = factory.linear_ring([p00, p11, p20, p00])
    ring.length                    # returns 4.82842712...
    ring.distance(p11)             # returns 0
    poly = factory.polygon(ring)
    poly.area                      # returns 1

### 3.6. Serialization

The SFS defines two serialization schemes for geometric objects, known as the
WKT (well-known text) and WKB (well-known binary) formats. The WKT is often
used for textual display and transmission of a geometric object, while the WKB
is sometimes used as an internal data format by spatial databases. Geometric
objects in RGeo define the `as_text` and `as_binary` methods to serialize the
object into a data string, while RGeo factories provide `parse_wkt` and
`parse_wkb` methods to reconstruct geometric objects from their serialized
form.

    p00 = factory.point(0, 0)
    p00.as_text                     # returns "POINT (0.0 0.0)"
    p10 = factory.point(1, 0)
    line = factory.line(p00, p10)
    line.as_text                    # returns "LINESTRING (0.0 0.0, 1.0 0.0)"
    p = factory.parse_wkt('POINT (3 4)')
    p.x                             # returns 3.0

Note that there are several key shortcomings in the WKT and WKB formats as
strictly defined by the SFS. In particular, neither format has official
support for Z or M coordinates, and neither provides a way to specify the
coordinate system (i.e. spatial reference ID) in which the object is
represented. Because of this, variants of these formats have been developed.
The most important to know are probably the EWKT and EWKB (or "extended"
well-known formats) used by the PostGIS database, which supports Z and M as
well as SRID. More recent versions of the SFS also have defined extensions to
handle Z and M coordinates, but do not embed an SRID. RGeo supports parsing
and generating these variants through the RGeo::WKRep module.

## 4. Coordinate Systems and Projections

So far, we have discussed geometric data and operations mostly without
reference to coordinate system. However, coordinate system is a critical
component for interpreting what a piece of data means. If you have a point (1,
2), are the 1 and 2 measured in meters? Miles? Degrees? And where are they
measured from? What is the origin (0, 0), and what directions do X and Y
represent?

Generally, the spatial technologies we're discussing are used to represent
location, objects on the earth's surface. In this section, we'll cover the
coordinate systems that you'll use for geolocation, as well as the issues
you'll face.

### 4.1. The World is Not Flat

First off, most of us agree that the earth is not flat, but has a shape
resembling a slightly flattened ball. This immediately results in a whole host
of complications when dealing with geometric objects on the earth's surface.
Distance can't quite be computed accurately using the familiar formulas you
learned in high school geometry. Lines that start off parallel will eventually
cross. And if you try to display things on a flat computer monitor, you will
end up with various kinds of distortion.

Let's take a simple example. Suppose we have a simple LineString with two
points: starting in Vancouver, Canada, and ending in Frankfurt, Germany, both
located at around 50 degrees north latitude. The LineString would consist of a
straight line between those two points. But what is meant by "straight"? Does
the shape follow the 50 degrees north latitude line, passing through
Newfoundland? Or does it follow the actual shortest path on the globe, which
passes much further north, close to Reykjavik, Iceland? (For a detailed
explanation, see Morten Nielsen's post ["Straight Lines on a Sphere"]
(http://www.sharpgis.net/post/2008/01/12/Straight-lines-on-a-sphere.aspx),
which also includes some helpful diagrams.) If you were to call the SFS
"distance" function to measure the distance between this LineString and a
Point located at Reykjavik, what would you get?

The answer is, it depends on the coordinate system you're using.

### 4.2. Geographic Coordinates And Projections

GIS systems typically represent locations in one of three different types of
coordinate systems: geocentric coordinates, geographic coordinates, and
projected coordinates. Geocentric coordinate systems typically locate the
origin of a three-dimensional Cartesian coordinate system at the center of the
earth. They are not commonly used in an application-level interface, but are
often a convenient coordinate system for running computational geometry
algorithms. Geographic coordinates use the familiar latitude and longitude
measurements, and sometimes also include altitude. These coordinates use a
curved surface, either a sphere or an ellipsoid, as the domain, and perform
geometric calculations on that non-flat domain. Projected coordinates involve
transforming the curved domain of the earth's surface onto a flat domain such
as a map display. Projected coordinates, then, are actually X-Y coordinates on
the map itself: for example, pixel coordinates.

In our Vancouver to Frankfurt example, the path of a "straight" line is
defined by the type of coordinate system being used. A geocentric coordinate
system operates in 3-d space, and so a straight line will actually pass
through the interior of the earth. A straight line in a geographic coordinate
system (latitudes and longitudes) is typically defined as a geodesic, the
shortest path between two points along the earth's surface. This path will
take the line near Reykjavik. In a projected coordinate system, a straight
line is defined as a straight line on the projection-- that is, a straight
line drawn on the flat map. Google and Bing maps use a Mercator projection, in
which lines of latitude are straight horizontal lines, so the LineString will
follow the 50 degrees latitude line, passing through Newfoundland.

It is important to note that the actual *shape* of the geometry is different
depending on the coordinate system. If you "project" the geodesic (the
straight Line in geographic coordinates) into a Mercator-projected Google map,
the line will be curved. Therefore, the coordinate system is an integral part
of the geometric object. If you get your coordinate systems mixed up, you may
get incorrect results when you run a database query or a geometric operation.
Morten Nielsen gives an example in [this post]
(http://www.sharpgis.net/post/2009/02/06/Why-EPSG4326-is-usually-the-wrong-e2809cprojectione2809d.aspx).

    flat_factory = RGeo::Geos.factory
    curved_factory = RGeo::Geographic.spherical_factory
    flat_line = flat_factory.line(flat_factory.point(0, 0),
                                  flat_factory.point(1, 1))
    curved_line = curved_factory.line(curved_factory.point(0, 0),
                                      curved_factory.point(1, 1))
    # flat_line and curved_line represent different shapes!

RGeo provides access to different coordinate systems via its factories, as we
saw earlier. If you are implementing geolocation, you will typically use one
of the geographic factories which represent coordinates as latitude and
longitude. Note, however, that RGeo provides both projected and non-projected
geographic factories. Projected factories are tied to a particular projection,
representing coordinates as latitude and longitude, but doing calculations in
the projection. If you use the simple mercator factory, a projected factory,
the line between Vancouver and Frankfurt will follow the 50 degree latitude
line, and so it will intersect a polygon representing Newfoundland.
Non-projected factories perform calculations on a curved earth. Using the
spherical factory, a non-projected factory that assumes the earth is a sphere,
the line between Vancouver and Frankfurt will intersect a polygon representing
Greenland. (In the future, RGeo should also provide an ellipsoidal factory
that performs the more complex calculations needed to model the earth as a
*flattened* sphere. This feature is not available yet.)

Some database systems behave similarly. PostGIS, for example, provides
separate "geometry" and "geography" types. The former assumes a flat domain:
it will behave similarly to RGeo's simple mercator factory for a horizontal
line (though for an oblique line, it will behave differently since the
vertical axis is nonuniform in the Mercator projection.) The PostGIS
"geography" type, however, operates on a curved earth, similar to RGeo's
spherical factory.

Does this matter in your application? The answer is, it depends: on what kind
of data you have, how it will be analyzed or displayed, and how much accuracy
you need. For a simple application that displays point locations or
small-scale paths and areas on a Google map, you can probably safely ignore
the issue. It would probably be easiest to simply use RGeo's non-projected
spherical factory, and the "geography" type if you are using PostGIS. The
Google maps system automatically transforms your latitude-longitude
coordinates into projected map coordinates when it displays markers and
polygons. Remember the Vancouver to Frankfurt problem, however: if you display
a line or polygon that is very large, the straight sides as displayed on the
Google map may not be straight on the actual curved earth, and a LineString
represented as a non-projected geographic object should not appear straight on
the map. If your objects cover large areas of the globe, or for better
accuracy or more sophisticated applications, you will need to pay explicit
attention to projections.

### 4.3. Geodetic and Projection Parameters

This subsection covers some more advanced topics that most developers may not
need to deal with directly, but I believe it is important to have at least a
high-level understanding of them.

Simply put, there's more to a coordinate system than just the type:
geocentric, geographic, or projected. For a geocentric coordinate system, we
know it's centered at the center of the earth, but where *is* the center of
the earth? Which direction do the axes point? And do we measure the units in
meters, miles, or light-years? For a geographic coordinate system, again, we
need a center and orientation (i.e. where is the "zero longitude" line?), but
we also need to define specifically *which* "latitude". The latitude commonly
used is the "geodetic latitude", which is the angle between the equator and
what is normal (i.e. vertical) to the surface of the earth. This means it is
dependent on one's model of the earth's surface, whether you use a sphere or a
flattened ellipsoid, and how much flattening you choose. The same location on
the earth's surface may have different latitudes depending on which system you
use! As for projected systems, not only do we need to specify which projection
to use (and there are hundreds defined), but we also need to know which
geographic (latitude-longitude) system to start from. That is, because a map
projection is a function mapping latitude/longitude to flat coordinates, we
need to specify *which* latitude/longitude.

To completely specify a coordinate system, then, a number of parameters are
involved. Below I briefly describe the major parameters and what they mean:

**Ellipsoid**: (Also called a **sphereoid**) An ellipsoid is an approximation
of the shape of the earth, defined by the length of the **semi-major axis**,
or the radius at the equator (measured in meters) and the **inverse
flattening** ratio, defined as the ratio between the semi-major axis, and the
difference between the semi-major and semi-minor axes. Note that the earth is
not a true ellipsoid, both because the gravitational and centrifugal bulging
is not solved exactly by an ellipsoid, and because of local changes in gravity
due to, for example, large mountain ranges. However, an ellipsoid is commonly
used for cartographic applications. The ellipsoid matters because it defines
how latitude is measured and what path will be followed by a "straight" line
across the earth's surface.

**Datum**: This is a reference location against which measurements are made.
There are generally two types of datums: horizontal datums, which define
horizontal (e.g. latitude-longitude) coordinate systems, and vertical datums,
which define the "zero altitude" point against which altitude measurements are
made.

The most common datum in use, and generally the one you will encounter most
often when writing location applications, is **WGS84**. This datum comprises
both horizontal and vertical parts. The WGS84 horizontal datum defines the
latitudes and longitudes used by the global positioning system (GPS).
Latitudes are defined using the WGS84 reference ellipsoid, using the standard
geodetic definition of the angle from the normal to the ellispoid. Longitudes
are measured relative to the *prime meridian*. (Interestingly, the WGS84 prime
meridian is not exactly on the historical Greenwich prime meridian that passes
through the Royal Observatory. A shift of about 100 meters to the east was
made in order to make WGS84 more closely match a commonly-used North
America-specific datum.)

The WGS84 vertical datum is a bumpy ellipsoid representing nominal sea level
for all parts of the earth. This shape is also known as the **geoid**.

A geographic coordinate system is generally defined by a datum and a prime
meridian. A projected coordinate system starts from a geographic coordinate
system and includes additional parameters specific to the projection.

Which coordinate system should you use for location data? The usual simple
answer is WGS84. Because this is the same worldwide geographic coordinate
system that GPS uses, as do most geocoding services and so forth, most of the
data you will encounter will be in WGS84. Only in certain locale-specific
cases might a different coordinate system be in common use. However, remember
that WGS84 is a geographic coordinate system, not a projected coordinate
system. It does not make sense to say that your map uses WGS84, because
chances are your map is a flat map, not a map wrapped around the WSG84
ellipsoidal shape.

What about Google and Bing maps? They use a combination of two coordinate
systems with a projection. The API inputs take latitude and longitude in the
WGS84 coordinate system. However, the maps themselves are Mercator projections
(with a minor modification to make computations easier), and so the map
implementations transform the coordinates internally. Again, Morten Nielsen
provides a more [detailed description]
(http://www.sharpgis.net/post/2007/07/27/The-Microsoft-Live-Maps-and-Google-Maps-projection.aspx).

### 4.4. Using Proj4

Under most circumstances, when you're working with geographic data in RGeo,
you can probably use either the spherical factory (if you just want to deal
with points on the sphere) or the simple mercator factory (if you want to deal
with objects as they would appear on Google or Bing maps). However, if you
need to work with arbitrary projections, you can use
[Proj](http://trac.osgeo.org/proj/), a C library that understands coordinate
systems and handles the math involved. Proj defines a syntax for specifying
coordinate systems based on the above parameters, and provides an
implementation for transforming coordinates from one coordinate system to
another. Its syntax has become a *de facto* standard.

RGeo provides a Ruby wrapper around the Proj interface, and integrates proj
into its representation of geometric objects. You can use the Proj syntax to
specify the coordinate system for input data, and tell RGeo to translate it to
a different coordinate system for analysis or output. RGeo's geographic
factories can also be configured with a particular projection using the Proj
syntax, and automatically convert between latitude-longitude and that
projection's coordinate system. For example:

    # Geographic factory that projects to a world mercator projection.
    # Note the ellps and datum set to WGS84.
    factory = RGeo::Geographic.projected_factory(:projection_proj4 =>
      '+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs')

    # Create a point with the long/lat of Seattle
    point = factory.point(-122.3, 47.6)

    # Project the point to mercator projection coordinates.
    # The coordinates are in "meters" at the equator.
    point.projection.as_text   # => "POINT (-13614373.724017357 6008996.432357133)"

### 4.5. Spatial Reference Systems and the EPSG Dataset

The OGC also defines a syntax for specifying coordinate systems, the
[Coordinate Transformation Services
Specification](http://www.opengeospatial.org/standards/ct). This specification
defines both an object model and a well-known text representation for
coordinate systems and transformations. RGeo also provides basic support for
this specification; you can attach an OGC coordinate system specification to a
factory to indicate the coordinate system. However, if you want RGeo to
convert spatial data between coordinate systems, you must use Proj4 syntax.

Finally, there also exists a *de facto* standard database of coordinate
systems and related parameters, published by EPSG (now the OGP Geomatics
Committee). This is a set of coordinate systems, each tagged with a well-known
ID number, including geographic and projected systems. You can browse this
database, including both OGC and Proj4 representations, at
http://www.spatialreference.org/. This database is also included as a table in
many popular spatial databases including PostGIS and SpatiaLite. Typically,
the EPSG number is used as the SRID identifying the coordinate system for
geometric objects stored in the database.

The most common EPSG number in use is 4326, which identifies the WGS84
geographic (longitude-latitude) coordinate system on the WGS84 ellipsoid. In
fact, current versions of PostGIS restrict geography objects to this SRID. Be
aware, again, that this is a non-projected ellipsoidal coordinate system. If
you load EPSG 4326 data directly into, say, a Cartesian implementation in
RGeo, then the basic data fields will work fine, but size and distance
functions, as well as spatial analysis operations such as intersections, may
yield surprising or incorrect results because the data's coordinate system
does not match how RGeo is treating it.

The EPSG database is so ubiquitous that it is commonly distributed along with
spatial database systems such as PostGIS and SpatiaLite, as described in the
next section. RGeo takes advantage of this by providing automatic lookup of
the coordinate system from the EPSG number. If you use one of these spatial
databases, you do not need to know the exact definition of the coordinate
system; just provide the EPSG number in the SRID field, and the RGeo factory
will know how to construct the correct Proj4 syntax for performing coordinate
conversions. You can even create custom spatial reference system databases if
you do not want to use the provided standard databases.

## 5. Spatial Databases

Now that we have a basic understanding of geospatial data, we'll turn to the
question of storing and querying for this data.

As we have seen, there exist a variety of ways to serialize geometric objects,
notably the OGC "well-known text" and "well-known binary" formats. The
simplest way to store such objects in a database, then, is to simply serialize
the object into a blob. However, this would not allow us to perform queries
with conditions relating to the object itself. Typical location-based
applications may need to run queries such as "give me all the locations within
one mile of a particular position." This kind of capability is the domain of
spatial databases.

### 5.1. Spatial Queries and Spatial Indexes

The OGC defines a
[specification](http://www.opengeospatial.org/standards/sfs), related to the
SFS, describing SQL extensions for a spatial database. This specification
includes a table for spatial reference systems (that is, coordinate systems)
which can contain OGC and Proj4 representations, and a table of metadata for
geometry columns which stores such information as type, dimension, and srid
constraints. It also defines a suite of SQL functions that you can call in a
query. For example, in a compliant database, to find all rows in "mytable"
where the geometry-valued column "geom" contains data within 5 units of the
coordinates (10, 20), you might be able to run a query similar to:

    SELECT * FROM mytable WHERE ST_Distance(geom, ST_WKTToSQL("POINT (10 20)")) > 5;

Like all database queries, however, when there are a large number of rows,
such a query can be slow if it has to do a full table scan. This is especially
true if it has to evaluate geometric functions like the above, which can be
numerically complex and slow to execute. To speed up queries, it is necessary
to index your spatial columns.

Spatial indexes are somewhat more complex than typical database indexes. A
typical B-tree index relies on a global ordering of data: the fact that you
can sort scalar values in a binary tree and hence perform logarithmic-time
searches. However, there isn't an obvious global ordering for spatial data.
Should `POINT (0 1)` come before or after `POINT (1 0)`? And how do each of
those compare with `LINESTRING (0 1, 1 0)`? Becase spatial data exists in two
dimensions rather than one, and can span finite ranges in additional to
infinitesimal points, the notion of a global ordering becomes ill-defined, and
normal database indexes do not apply as well as we would like.

Spatial databases handle the problem of indexing spatial data in various ways,
but most techniques are variants on an indexing algorithm known as an R-tree.
I won't go into the details of how an R-tree works here. For the interested, I
recommend the text ["Spatial Databases With Application To
GIS"](http://www.amazon.com/dp/1558605886), which covers a wide variety of
issues related to basic spatial database implementation. For our purposes,
just note that for large datasets, it is necessary to index the geometry
columns, and that the index creation process may be different from that of
normal scalar columns. The next sections provide some information specific to
some of the common spatial databases.

### 5.2. MySQL Spatial

[MySQL](http://mysql.com/) maintains its dual reputation as probably the
easiest of the open source relational databases to manage, but as tending to
miss some features and standards compliance. Recent versions of MySQL have
spatial column support baked in, and they are extremely easy to use: just
create a column of type GEOMETRY, or POINT, or LINESTRING, or any of the OGC
types. You can also create spatial indexes simply by adding the SPATIAL
modifier to CREATE INDEX. Note, however, that as of MySQL 5.1, only MyISAM
tables support spatial indexes. If you're using Innodb, you can add spatial
columns but you can't index them.

    CREATE TABLE mytable(id INT NOT NULL PRIMARY KEY, latlon POINT) ENGINE=MyISAM;
    CREATE SPATIAL INDEX idx_latlon ON mytable(latlon);

MySQL represents data internally using a variant of WKB which has been
slightly modified by prepending 4 extra bytes to store an object's SRID. You
can interpret this data directly, or use provided functions to convert to and
from WKB and WKT.

What MySQL lacks is support for most of the advanced spatial geometry
functions such as the relational operators (e.g. ST_Intersects(),
ST_Contains(), etc.), so you will not be able to perform complex geometric
calculations using the database engine. You'll have to just load the data into
your application and use RGeo to perform those calculations. It also does not
provide the OGC-specified geometry columns or spatial reference system tables.
Because the former table is not present, you will not be able to specify
constraints on your geometries beyond the type: you will not be able to
constrain the SRID for a column, and columns will not be able to support Z and
M coordinates. Because the latter table is not present, MySQL cannot perform
coordinate system transformations itself, nor provide you with the standard
EPSG dataset for your own use.

In general, if you're using MySQL for the rest of your application, and you
just need simple geospatial data capabilities, it's very easy to use MySQL
spatial. Just make sure your table uses the MyISAM engine if you need to index
the geometry.

### 5.3. SpatiaLite

[SpatiaLite](http://www.gaia-gis.it/spatialite/) is an add-on library for the
popular database [Sqlite](http://www.sqlite.org/). It is close to a fully
compliant implementation of the OGC SQL specification, but as a result it is
more difficult to manage than MySQL.

To install SpatiaLite, you must compile it as a shared library, then load that
library as an extension using the appropriate sqlite API. This gives you
access to the full suite of spatial SQL functions defined by the OGC, along
with a set of utility functions for managing spatial columns and indexes as
well as the geometry columns and spatial reference systems tables. These
utility functions automatically create and manage the appropriate entries in
the geometry columns table and the triggers that enforce type and SRID
constraints and maintain the spatial indexes.

    CREATE TABLE mytable(id INTEGER PRIMARY KEY);
    SELECT AddGeometryColumn('mytable', 'latlon', 4326, 'POINT', 'XY');
    SELECT CreateSpatialIndex('mytable', 'latlon');

Spatial indexes themselves are implemented using SpatiaLite's Rtree extension,
and so queries that use a spatial index are a little more complex to write.
You have to join to the Rtree table, or use a nested query:

    SELECT * FROM mytable WHERE id IN
      (SELECT pkid FROM idx_mytable_latlon WHERE
         xmin > -123 AND xmax < -122 AND ymin > 47 AND ymax < 48);

SpatiaLite's internal format is a binary format loosely based on the WKB, but
extended to include the SRID, as well as some internal bounding rectangle data
to speed up calculations. Like MySQL, SpatiaLite provides functions to convert
this data to and from WKB and WKT. I'm not completely clear on this, but it
does not seem that SpatiaLite supports Z and M coordinates at this time.

### 5.4. PostGIS

As [PostgreSQL](http://www.postgresql.org/) is the most complete (and complex)
open-source relational database, so the [PostGIS](http://www.postgis.org/)
add-on library is also the most complete and complex of the spatial databases
I discuss here. It is a highly compliant implementation of the OGC SQL
specification, including all the needed functions and tables. It also supports
spatial indexes using PostgreSQL's GiST (generalized search tree) index
implementation.

Like SpatiaLite, PostGIS is compiled and installed as a plug-in library to the
database. Also like SpatiaLite, PostGIS provides a suite of utility functions
for managing spatial columns and updating the geometry columns table. PostGIS
indexes, however, are built in, and so use the more traditional index creation
syntax. Like SpatiaLite, PostGIS provides a spatial reference systems table
from which you can look up EPSG codes and obtain Proj4 and OGC representations
of coordinate systems.

    CREATE TABLE mytable(id INTEGER PRIMARY KEY);
    SELECT AddGeometryColumn('mytable', 'latlon', 4326, 'POINTM', 3);
    CREATE INDEX idx_mytable_latlon ON mytable USING GIST (latlon);

PostGIS actually provides two types of spatial columns: geometry and
geography. The former assumes a flat coordinate system and performs
Euclidean/Cartesian geometric calculations using any EPSG coordinate system
you choose. The latter is specifically designed for geographic
(longitude-latitude) coordinate systems. It performs calculations on the
sphereoid and only works with EPSG 4326; however, some of the more advanced
functions are not implemented because the calculations involved would be
prohibitively complex. When you create a spatial column in PostGIS, you will
need to decide whether to use the geometry or geography type.

PostGIS uses as its internal format a variant of WKB known as EWKB. This
variant provides support for Z and M coordinates as well as embedded SRID
values. PostGIS also defines an corresponding EWKT format adding Z and M
support and SRIDs to WKT, and provides conversion functions. The EWKB and EWKT
variants are commonly used and so are supported by RGeo's WKB and WKT parsers.

### 5.5. RGeo ActiveRecord Integration

RGeo provides extra support for web applications built on Ruby On Rails or
similar frameworks that use the ActiveRecord library, in the form of a suite
of ActiveRecord connection adapters for the various spatial databases we have
covered. These connection adapters subclass the stock database connection
adapters, and add support for the RGeo geometric data types. You can create
spatial columns and indexes using extensions to the ActiveRecord schema
definition functions, and the appropriate fields on your ActiveRecord objects
will appear as RGeo spatial data objects. Some of these adapters also modify
ActiveRecord's rake tasks to help automate the process of creating and
maintaining spatial databases. Using one of these connection adapters is
probably the easiest way to integrate your Rails application with a spatial
database.

RGeo's spatial ActiveRecord adapters are provided in separate gems, named
according to the recommended convention. These are the names of these
connection adapters:

*   **mysqlspatial**: Subclasses the mysql adapter and adds support for
    MySQL's spatial types. Available as the
    **activerecord-mysqlspatial-adapter** gem.
*   **mysql2spatial**: Subclasses the mysql2 adapter and adds support for
    MySQL's spatial types. Available as the
    **activerecord-mysql2spatial-adapter** gem.
*   **spatialite**: Subclasses the sqlite3 adapter and adds support for the
    SpatiaLite extension. Available as the **activerecord-spatialite-adapter**
    gem.
*   **postgis**: Subclasses the postgresql adapter and adds support for the
    PostGIS extension. Available as the **activerecord-postgis-adapter** gem.


### 5.6. Commercial SQL Databases and Non-SQL Databases

Major commercial relational databases also include various levels of support
for the OGC SQL specification. Recent versions of the venerable Oracle
database include [Oracle
Spatial](http://www.oracle.com/technetwork/database/options/spatial/index.html
), and Microsoft's latest SQL Server also includes [spatial data
tools](http://www.microsoft.com/sqlserver/2008/en/us/spatial-data.aspx). I
have not had a chance to evaluate the spatial tools in these commercial
databases, though I have heard them described as "powerful, but moody". RGeo
does not yet have direct ActiveRecord support for Oracle or SQL Server
spatial.

Several "NoSQL" databases also provide various degrees of limited support for
geospatial data. Because these databases intentionally eschew the SQL
standard, there is no OGC-defined standard interface for these databases, and
so you will need to study the individual database's documentation to get an
idea of the capabilities and API. RGeo does not yet provide direct integration
support for non-relational databases, but in most cases, it should not be too
difficult to write glue code yourself.

[MongoDB](http://www.mongodb.org/) provides limited support for storing and
indexing point data. In the current stable release series (1.8.x), you can
store a point field as a longitude-latitude pair, and perform basic proximity
and bounds searches. It does not support LineString or Polygon data. As far as
I can determine, MongoDB uses a simple indexing system based on geo-hashing,
which also limits its ability to support non-point data.

[GeoCouch](http://github.com/couchbase/geocouch) is an addition to
[CouchDB](http://couchdb.apache.org/) that provides an r-tree-based spatial
index for point data. I have not studied it much, but it also appears to be
limited to point data.

## 6. Location Service Integration

When writing a location-aware application, you will often need to interact
with external sources of data and external location-based services. RGeo
provides several tools to facilitate this data transfer.

### 6.1. Shapefiles and Spatial Data Sets

[ESRI](http://www.esri.com/) is one of the oldest and most well-known GIS
corporations, developing a suite of applications including the venerable
[ArcGIS](http://www.esri.com/software/arcgis/index.html). ESRI also created
the Shapefile, a geospatial data file format that has become a *de facto*
standard despite its legacy and somewhat awkward characteristics. Today, many
of the widely-available geospatial data sets are distributed as shapefiles.

The shapefile format is specified in an ESRI
[whitepaper](http://www.esri.com/library/whitepapers/pdfs/shapefile.pdf). It
typically comprises three files: the main file "*.shp" containing the actual
geometric data, a corresponding index file "*.shx" providing offsets into the
.shp file to support random access, and a corresponding file "*.dbf" in dBASE
format that stores arbitrary attributes for the shape records. Many GIS
systems can read and/or write shapefiles. SpatiaLite can treat a shapefile as
an external "virtual table". An optional RGeo module, RGeo::Shapefile
(distributed as the gem **rgeo-shapefile**) can read shapefiles and expose
their contents as RGeo's geometric data types.

### 6.2. GeoJSON and Location-Based Services

Location is becoming a common feature of web services as well. An emerging
standard in the encoding of geographic data in a web service is
[GeoJSON](http://www.geojson.org/), an geospatial data format based on JSON.
GeoJSON can encode any of the OGR geometry types, along with attributes,
bounding boxes, and coordinate system specifications.
[SimpleGeo](http://www.simplegeo.com/) is one of several high-profile location
based APIs now using GeoJSON. RGeo also provides an optional module
RGeo::GeoJSON (distributed as the gem **rgeo-geojson**) that can read and
write this format.

Other common formats that may be used by web services include
[GeoRSS](http://www.georss.org/), an extension to RSS and Atom for geotagging
RSS feed entries, and [KML](http://www.opengeospatial.org/standards/kml), an
XML-based markup language for geographic information originally developed by
Google and recently adopted as an OGC standard. The GeoRuby library provides
rudimentary support for these formats. RGeo does not yet, but appropriate
optional modules are on the to-do list.

## 7. Conclusion

Geospatial systems represent a rapidly growing and evolving area of
technology, and helpful resources are often difficult to find outside of the
relatively niche GIS community. Writing a robust location-aware application
sometimes requires an understanding of a number of GIS concepts, tools, and
specifications. We have covered a few of the most important ones in this
document.

At the time of this writing, a number of open source geospatial tools and
libraries are starting to mature. For Ruby and Rails developers, the RGeo
library is one of these emerging tools, and represents an important step
towards supporting the next generation of geospatial applications.

## History

*   Version 0.1 / 5 Dec 2010: Initial draft
*   Version 0.2 / 7 Dec 2010: More code examples and other minor updates
*   Version 0.3 / 17 Feb 2011: Further minor clarifications and fixes, and
    coverage of features in newer RGeo releases
*   Version 0.4 / 23 May 2011: Minor updates to keep up with new releases

