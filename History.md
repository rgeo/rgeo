### 0.6.0 / 2017-3-1

* Require ruby 2.1+
* Remove repeated consecutive points from line-strings (ChapterMedia) #136
* Use canonical_point to validate line string (glampr) #152 #87
* Remove unused Geos methods (tneems) #151
* Remove RGeo.yaml_supported?
* Fix RGeo::Feature.cast errors (Dschee) #162 #147 #146
* Add Geometry#unary_union (ynelin, pRdm) #168 #110


### 0.5.3 / 2016-2-17

* Use rake-compiler to build extensions (tneems) #138
* Add Geos validation methods (ynelin) #112


### 0.5.2 / 2015-12-10

* Include .c and .h files in gem (fix typo in gemspec)


### 0.5.1 / 2015-12-10

* Exclude generated files from packaged gem
* Fix compile without Geos (deivid-rodriguez) #125


### 0.5.0 / 2015-12-10

* Add #buffer_with_style (ynelin) #108
* Prioritize lib and header directories of ruby managers (eddietejeda) #115
* Coordinates support (2d/3d/4d) (tneems) #119
* Remove RGeo::CoordSys::SRSDatabase::ActiveRecorTable
* Support JRuby 1.7, 1.9 (nextdayflight, deivid-rodriguez) #120
* Apply Rubocop style changes (deivid-rodriguez) #124


### 0.4.0 / 2015-08-27

*   Drop support for ruby 1.8.7, require ruby 1.9.3+
*   Add support for GEOS CAPI simplify (quidquid) #95
*   Antimerdian x coordinates (longitude: +180) are no longer sign flipped (longitude:-180) (ajturner) #89
*   Fix Marshal and Psych support for native geos factories (cjab) #84
*   Fix random_point to return point inside rectangle (glampr) #89

### 0.3.20 / 2012-12-08

*   Distances computed by the spherical factory were incorrect when covering
    more than 90 degrees of the globe. Fixed. (reported by exoth)


### 0.3.19 / 2012-09-20

*   The Geos factories, as well as the projected geographic convenience
    factories such as simple_mercator, now support the
    :uses_lenient_assertions option.
*   RGeo::Geographic::ProjectedWindow#height was incorrectly aliased to x_span
    rather than y_span. Fixed.


### 0.3.18 / 2012-09-19

*   The coordinate system WKT parser now recognizes the nonstandard
    "EXTENSION" node. This node is not part of the WKT, but it is present in
    some data sets, including the coordinate systems shipped with Proj 4.8, so
    we now support it.
*   Updated some of the other test cases to work with the specific data that
    ships with Proj 4.8.
*   New APIs to access the underlying version of Geos and Proj.


### 0.3.17 / 2012-08-21

*   Geos-based implementations crashed when an operation resulted in an empty
    point, e.g. taking the centroid of an empty MultiPolygon on recent
    versions of Geos. Fixed. Such operations now return the empty
    GeometryCollection for the time being, to match the behavior of older
    versions of Geos. (Reported by Ben Hughes)


### 0.3.16 / 2012-08-19

*   Added /usr/lib64 to the list of libraries searched. (Thanks to hunterae)
*   Re-added Geos::Factory as an alias of Geos::CAPIFactory, for compatibility
    with old serializations.


### 0.3.15 / 2012-08-02

*   The class shuffle in 0.3.14 broke RGeo::Geos.is_geos? and similar. Fixed.


### 0.3.14 / 2012-07-08

*   Compatibility note: The class names for some of the factory and feature
    implementations, as well as the superclass relationships, have changed in
    this release. These class names and hierarchy are internal, and clients
    should not depend on them. That is, RGeo types are generally duck-types.
    If you need to interrogate type, see the documentation for the
    ::RGeo::Feature::Type module.
*   The gemspec no longer includes the timestamp in the version, so that
    bundler can pull from github. (Reported by corneverbruggen)
*   Mixins were not being added to GEOS features with both Z and M coordinate.
    Fixed.
*   Mixins are added last to feature objects, so they should override anything
    added by other modules such as Enumerable. (Reported by Ben Hughes)
*   Some object hashes were not consistent with equality. Fixed. Hashes should
    now be consistent with representational equivalence (i.e. the eql?
    method). Therefore, it should now be possible to use RGeo factories and
    features as hash keys.


### 0.3.13 / 2012-05-04

*   The spherical factory and the simple cartesian factory now support buffers
    around points (but not around other types). Accordingly, those factories
    now take the :buffer_resolution property argument.
*   The :uses_lenient_assertions and parser/generator arguments to
    RGeo::Geographic.spherical_factory did not have their advertised effect.
    Fixed.
*   The parser/generator arguments to projected geographic factories did not
    have their advertised effect. Fixed.


### 0.3.12 / 2012-04-24

*   Geos::FFIFactory collection constructors sometimes modified arguments in
    place, which caused problems for the ZMFactory among other things. Fixed.


### 0.3.11 / 2012-04-14

*   Geometry#buffer crashed in the geos capi factory. Fixed.


### 0.3.10 / 2012-04-12

*   Implemented subdivision and other analysis features on
    Cartesian::BoundingBox.
*   Operators +, -, and * were not implemented in the ffi-geos factory. Fixed.


### 0.3.9 / 2012-04-10

*   Implemented LineString#length and MultiLineString#length for simple
    cartesian and simple spherical factories.
*   Added Cartesian::BoundingBox.create_from_points.
*   Serialization was broken for some 3d geometries when running libgeos 3.2.x
    (3.3.x was unaffected). Fixed.
*   Fixed an exception when creating adding a geometry to a
    Cartesian::BoundingBox when a cast is necessary.
*   Added configuration for Travis CI.


### 0.3.8 / 2012-03-23

*   When using the spherical factory, some negative longitudes might get
    perturbed slightly due to floating point errors. Fixed. (Reported by Pete
    Deffendol)
*   Fixed a bunch of warnings, and turned on warnings during testing.


### 0.3.7 / 2012-03-12

*   Marshal and YAML serialization now fully implemented for geometries.
*   The spatial predicates for objects using the 4D (ZM) Geos factory almost
    always returned false because they weren't casting correctly. Fixed.
*   Proj#canonical_str and the Geos implementations of Geometry#as_text were
    returning strings encoded as "ASCII-8BIT", which was causing strange
    binary output in YAML serialization, among other things. Now fixed. These
    strings are now encoded as "US-ASCII".
*   YAML serialization for 4D (ZM) Geos factories didn't preserve coordinate
    systems. Fixed.


### 0.3.6 / 2012-03-06

*   Geometry#relate? was incorrectly spelled "Geometry#relate" in the
    Feature::Geometry module and in some (but not all) implementations,
    leading to various types of method not found errors. Fixed. We'll keep
    #relate as a deprecated alias for the time being.
*   Cloning a Geos CAPI factory caused a segfault. Fixed.
*   Parsing a "well-known" format string using the ffi-geos implementation
    returned the low-level ffi-geos object rather than the RGeo feature if the
    generator was set to :geos. Fixed.
*   GeometryCollection#each now returns an Enumerator if no block is given.
*   Pure Ruby factories (simple_spherical, simple_cartesian) now support a
    :uses_lenient_assertions option, which disables assertion checking on
    LinearRing, Polygon, and MultiPolygon construction, since those checks can
    be expensive for large geometries.
*   Fixed Rails 3.2 deprecation warning in SRSDatabase::ActiveRecordTable.
*   Fixed an issue with the ActiveRecordTable tests on ActiveRecord 3.2.
*   Further work towards YAML and mashal serialization support. Factories are
    now done, but geometries are not. I'm working actively on geometry
    serialization; it should be in place in the next release.


### 0.3.5 / 2012-02-27

*   Reworked the terminology on equivalence levels. The documentation now
    names the three levels "spatial", "representational", and "objective"
    equivalence.
*   Some geometry implementations didn't implement the == operator, resulting
    in various problems, including inability to set ActiveRecord attributes
    when using an implementation (such as simple_spherical polygons) that
    doesn't provide spatial equivalence tests. Fixed. The interfaces now
    specify that all implementations must implement the == operator and the
    eql? method, and should degrade to stronger forms of equivalence if weaker
    forms are not available. (Reported by Phil Murray.)
*   Added Geometry#rep_equals? to test representational equivalence without
    the fallback behavior of Geometry#eql?


### 0.3.4 / 2012-02-21

*   The FFI-GEOS implementation now uses prepared geometries.
*   Fixed a segfault that sometimes happened when passing a non-GEOS geometry
    as an argument to a GEOS function under Ruby 1.8.7. (Reported by Greg
    Hazel.)
*   A few minor optimizations in the C extension for GEOS.


### 0.3.3 / 2011-12-19

*   Recognizes MultiPoint WKTs in which individual points are not contained in
    parens. This is technically incorrect syntax, but apparently there are
    examples in the wild so we are now supporting it. (Reported by J Smith.)
*   The Geos CAPI implementation sometimes returned the wrong result from
    GeometryCollection#geometry_n. Fixed.
*   Fixed a hang when validating certain projected linestrings. (Patch
    contributed by Toby Rahilly.)
*   Several rdoc updates (including a contribution by Andy Allan).
*   Separated declarations and code in the C extensions to avert warnings on
    some compilers.


### 0.3.2 / 2011-08-11

*   Some objects can now be serialized and deserialized via Marshal or YAML.
    Supported objects include OGC coordinate systems, Proj4 coordinate
    systems, and WKRep parsers/generators. Factories and geometries will be
    supported shortly.
*   The GEOS CAPI implementation can now use prepared geometries to speed up
    certain operations. The GEOS FFI implementation will do the same shortly.
*   Calling dup on a Proj4 object caused a segfault. Fixed.
*   Fixed an exception in RGeo::Cartesian::BoundingBox#to_geometry. (Thanks to
    Travis Dempsey.)
*   WKTGenerator generated incorrect tag names for subtypes of LineString.
    Fixed.
*   Installation automatically finds the KyngChaos GEOS and Proj4 frameworks
    for Mac OS X. (Thanks to benchi.)


### 0.3.1 / 2011-05-24

*   Running a == operator comparison between a geometry and a non-geometry
    caused an exception for some implementations. Fixed. (Reported by Daniel
    Hackney.)
*   Clarified the specifications for operators on geometry objects.


### 0.3.0 / 2011-05-23

*   RGeo can now use GEOS via the ffi-geos gem, in addition to RGeo's built-in
    C integration. The ffi-geos integration is experimental right now, since
    ffi-geos is still in early beta. In particular, I do not recommend using
    it in JRuby yet (as of JRuby 1.6.1), because an apparent JRuby bug
    (JRUBY-5813) causes intermittent segfaults. However, once the issue is
    resolved (soon, I hope, since I've already submitted a patch to the JRuby
    team), we should have GEOS functional on JRuby.
*   It is now possible to add methods to geometry objects "globally". This was
    not possible previously because there is no global base class; however,
    there is now a mechanism to specify mixins that all implementations are
    expected to include.
*   Added RGeo::Feature::Type.supertype and each_immediate_subtype.
*   POSSIBLE INCOMPATIBLE CHANGE: Taking the boundary of a GEOS
    GeometryCollection now returns nil. It used to return an empty
    GeometryCollection, regardless of the contents of the original collection.
    GeometryCollection subclasses like MultiPoint, however, do have proper
    boundaries.
*   Renamed the lenient_multi_polygon_assertions GEOS factory parameter to
    uses_lenient_multi_polygon_assertions. The older name will continue to
    work.
*   The GEOS buffer_resolution and uses_lenient_multi_polygon_assertions
    options are now exposed via properties.
*   The RGeo::Feature::Polygon module incorrectly included Enumerable. Fixed.
*   Several of the implementations included some extraneous (and
    nonfunctional) methods because they included the wrong modules. Fixed.


### 0.2.9 / 2011-04-25

*   INCOMPATIBLE CHANGE: mutator methods for the configurations of the WKRep
    parsers and generators have been removed. Create a new parser/generator if
    you need to change behavior.
*   POSSIBLE INCOMPATIBLE CHANGE: The GEOS implementation now uses WKRep (by
    default) instead of the native GEOS WKB/WKT parsers and generators. This
    is because of some issues with the GEOS 3.2.2 implementation: namely, that
    the GEOS WKT generator suffers from some floating-point roundoff issues
    due to its "fixed point" output, and that the GEOS WKT parser fails to
    recognize names not in all caps, in violation of the version 1.2 update of
    the SFS. (Thanks to sharpone74 for report GH-4.)
*   WKRep::WKTGenerator injects some more whitespace to make output more
    readable and more in line with the examples in the SFS.
*   It is now possible to configure the WKT/WKB parsers/generators for each of
    the implementations, by passing the configuration hash to the factory
    constructor. In addition, it is also possible to configure the GEOS
    factory to use the native GEOS WKT/WKB implementation instead of
    RGeo::WKRep (that is, to restore the behavior of RGeo <= 0.2.8).
*   The WKB parser auto-detects and interprets hex strings.


### 0.2.8 / 2011-04-11

*   A .gemspec file is now available for gem building and bundler git
    integration.


### 0.2.7 / 2011-04-09

*   POSSIBLE INCOMPATIBLE CHANGE: GeometryCollection#geometry_n,
    Polygon#interior_ring_n, and LineString#point_n, in some implementations,
    allowed negative indexes (which counted backwards from the end of the
    collection as per Ruby arrays). This was contrary to the SFS interface,
    and so the behavior has been removed. However, GeometryCollection#[],
    because it is supposed to model Ruby arrays, now explicitly DOES allow
    negative indexes. This means GeometryCollection#[] is no longer exactly
    the same as GeometryCollection#geometry_n. These clarifications have also
    been made in the RDoc.
*   The GEOS implementations of GeometryCollection#geometry_n and
    Polygon#interior_ring_n segfaulted when given an index out of bounds.
    Bounds Check Fail fixed. (Reported by sharpone74.)


### 0.2.6 / 2011-03-31

*   Ring direction analysis raised an exception if any of the line segments
    were zero length. Fixed. (Reported by spara.)


### 0.2.5 / 2011-03-21

*   Line segment intersection tests in the simple cartesian implementations
    were failing for a few cases involving collinear segments. Fixed.
    (Reported by Dimitry Solovyov.)
*   Argument hash RDocs should be more readable.


### 0.2.4 / 2010-12-31

*   Several bugs were preventing the low-level Proj4 transform functions from
    working at all. Fixed. (Reported by mRg.)
*   The GEOS factories over-optimized projection casts, sometimes resulting in
    proj4 transformations not getting applied. Fixed. (Reported by mRg.)
*   Proj4 objects now have a flag to indicate whether geographic coordinate
    systems should be in radians. The (undocumented) radians option is no
    longer supported in transform_coords.
*   Disabled the spatialreference.org tests for the time being because the
    site seems to be offline.


### 0.2.3 / 2010-12-19

*   The "simple mercator" geographic type incorrectly reported EPSG 3857
    instead of EPSG 3785 for the projection. Dyslexia fixed.
*   Geographic types couldn't have their coord_sys set. Fixed.
*   You can now pass an :srs_database option when creating most factory types.
    This lets the factory look up its coordinate system using the given SRID.
*   There are now explicit methods you can call to obtain FactoryGenerator
    objects; you should not need to call `method`.
*   Wrote RDocs for all the CoordSys::CS and CoordSys::SRSDatabase classes.


### 0.2.2 / 2010-12-15

The main theme for this release was support for spatial reference system
databases. The basic functionality is done and ready for experimentation.
However, documentation is still in progress, and we're still working on some
ideas to make coordinate system management more seamless by integrating the
SRS databases with FactoryGenerator.

*   Implemented OGC coordinate system objects, including most of the CS
    package of the OGC Coordinate Transform spec, and a parser for the WKT.
*   Defined interfaces for spatial reference system database access.
    Implemented a database based on ActiveRecord and backed by spatial_ref_sys
    tables; one based on the data files shared by the proj4 library; one based
    on retrieving data from spatialreference.org, and one based on retrieving
    data from arbitrary URLs.
*   Renamed RGeo::Feature::Type::Instance marker module to
    RGeo::Feature::Instance. The old name is aliased for backward
    compatibility but is deprecated.
*   Added a few more directories to the default lookup path for geos and
    proj4.


### 0.2.1 / 2010-12-09

*   Now compatible with Rubinius (version 1.1 or later).
*   Now partially compatible with JRuby (1.5 or later). A bunch of tests fail
    because GEOS and Proj4 are not available, hence there is no projection
    support and no complete Cartesian implementation. But at least RGeo loads
    and the basic operations work.
*   Some minor optimizations in the GEOS glue code.


### 0.2.0 / 2010-12-07

This is the first public alpha version of RGeo. With this version, we are
soft-locking the API interfaces and will try to retain backwards compatibility
from this point. Incompatible API changes may still be done, but only if
considered necessary.

With this release, RGeo has been split into a core library and a set of
optional modules. The following modules remain in the core "rgeo" gem:
*   RGeo::Feature
*   RGeo::CoordSys
*   RGeo::Geos
*   RGeo::Cartesian
*   RGeo::Geographic
*   RGeo::WKRep


The following modules have been spun off into separate gems:
*   RGeo::GeoJSON has been spun off into the "rgeo-geojson" gem.
*   RGeo::Shapefile has been spun off into the "rgeo-shapefile" gem.
*   RGeo::ActiveRecord has been spun off into the "rgeo-activerecord" gem.


The ActiveRecord adapters have been spun off into gems according to the
recommended ActiveRecord naming scheme:
*   The **mysqlspatial** adapter is now in the gem
    "activerecord-mysqlspatial-adapter".
*   The **mysql2spatial** adapter is now in the gem
    "activerecord-mysql2spatial-adapter".
*   The **spatialite** adapter is now in the gem
    "activerecord-spatialite-adapter".
*   The **postgis** adapter is now in the gem "activerecord-postgis-adapter".


Any additional modules likely will be distributed similarly as separate gems.

Other changes in this version:
*   API CHANGE: Renamed UnsupportedCapability to UnsupportedOperation since
    we've done away with the "capability" concept.
*   Proj4 integration wasn't building into the right location on a gem
    install. Fixed.
*   Various updates to the rdocs.
*   Minor updates to the Spatial Programming paper.


### 0.1.22 / 2010-12-05

This should be the last pre-alpha development version. The next version
planned is the 0.2 alpha release.

*   API CHANGE: Renamed Geography module to Geographic.
*   API CHANGE: Renamed Factory#has_capability? to Factory#property to
    generalize the API.
*   API CHANGE: Factory#proj4 and Factory#coord_sys are now required methods.
*   The ZM Geos factory didn't properly handle proj4. Fixed.
*   The proj4-based projected geographic factory now extracts the
    cooresponding geographic coordinate system from the projection, rather
    than always using WGS84.
*   Initial draft of Spatial Programming paper.


### 0.1.21 / 2010-12-03

*   API CHANGE: Added "_factory" to the end of the Geography toplevel
    interface methods, for consistency with the rest of the API.
*   API CHANGE: Simplified initializer API for WKTParser and WKBParser.
*   API CHANGE: Removed ActiveRecord::Base.rgeo_default_factory, and provided
    a reasonable default rgeo_factory_generator.
*   Removed deprecated pluralized names RGeo::Features and RGeo::Errors.
*   First pass implementation of the ActiveRecord adapters for SpatiaLite and
    PostGIS.
*   Fixed problems with Proj4 equivalence testing.
*   Several more minor fixes and documentation updates.


### 0.1.20 / 2010-11-30

*   API CHANGE: Methods that raised MethodUnimplemented now raise
    UnsupportedCapability instead. Removed MethodUnimplemented.
*   API CHANGE: Renamed RGeo::Features to RGeo::Feature, RGeo::Errors to
    RGeo::Error, and RGeo::ImplHelpers to RGeo::ImplHelper. The old pluralized
    names are aliased to the new names for now for backward compatibility,
    though they are deprecated and will be removed shortly.
*   Renamed the tests directory to test. Generally speaking, I'm getting rid
    of pluralized names.
*   Added RGeo::CoordSys::Proj4 representing a proj4 coordinate system. It
    uses the proj4 library.
*   Added Factory#proj4 as an optional method indicated by the :proj4
    capability.
*   All existing geometry implementations now support proj4.
*   You can now cause casting to transform between proj4 projections by
    specifying the :project parameter.
*   A Geography implementation with an arbitrary projection backed by proj4 is
    now available.


### 0.1.19 / 2010-11-23

*   The GEOS implementation now supports ZM (4-dimensional data), via a
    wrapper since the underlying GEOS library doesn't support 4d data
    natively.
*   Added a BoundingBox tool to the Cartesian module.
*   Fleshed out a few more methods of SimpleCartesian and SimpleSpherical.
*   The simple Cartesian point implementation included a bit more leakage from
    the Geography implementations (pole equivalence, lat/lon methods). Fixed.
*   Under certain circumstances, collections and polygons using GEOS could
    lose their Z or M coordinates. Fixed.
*   There were some cases when implementations based on ImplHelpers were
    pulling in the wrong methods. Fixed.
*   Taking the envelope of an empty GEOS collection yielded an illegal object
    that could cause a crash. Fixed. It now yields an empty collection.
*   Taking the boundary of an empty GEOS collection yielded nil. Fixed. It now
    yields an empty collection.


### 0.1.18 / 2010-11-22

*   API CHANGE: GeoJSON defaults to no JSON parser rather than to the JSON
    library. GeoJSON also fails better when attempting to use a JSON parser
    that isn't installed.
*   Added a decorator tool for FactoryGenerator
*   Added an analysis module for Cartesian geometries, and implemented an
    algorithm for determining whether a ring is clockwise or counterclockwise.
    (We needed this to interpret shapefiles.)
*   First pass implementation of shapefile reading. It passes a basic test
    suite I borrowed from shapelib, but I haven't yet done an exhaustive test
    on every case.
*   The simple Cartesian implementation mistakenly clamped x and y to lat/lon
    limits. Fixed.


### 0.1.17 / 2010-11-20

*   Implemented ActiveRecord adapters that cover MySQL Spatial for the mysql
    and mysql2 gems. SpatiaLite and PostGIS adapters are coming later.
*   Added and documented FactoryGenerator.
*   API CHANGE: WKRep parsers now take FactoryGenerator rather than the ad-hoc
    factory_from_srid.
*   API CHANGE: Factory#override_cast now takes its optional flags in a hash
    so it can be extended more cleanly in the future.


### 0.1.16 / 2010-11-18

*   Test coverage for WKB generator and parser; fixed a few bugs.
*   Eliminated the hard dependency on the JSON gem, and allow configuration of
    GeoJSON with an alternate JSON parser such as YAJL or ActiveSupport.
*   API CHANGE: geo factory is now a hash option in GeoJSON, and is now
    optional.
*   GeoJSON now handles Z and M coordinates, according to the capabilities of
    the geo factory.
*   GeoJSON feature objects can now handle null geometry and null properties,
    per the spec.
*   Factory::cast now optionally lets you pass the parameters as a hash.


### 0.1.15 / 2010-11-08

*   Cleanup, fixes, documentation, and partial test coverage in the WKT/WKB
    implementations.
*   Implemented autoload for the various modules.
*   A few minor fixes.


### 0.1.14 / 2010-11-04

*   Introduced capability checking API.
*   Standardized API and semantics for handling of points with Z and/or M
    coordinates.
*   Fixed several problems with Z coordinates in GEOS.
*   Fixed exceptions and wrong values returned from GEOS
    LineString#start_point and LineString#end_point.
*   Fixed crash in GEOS LineString#point_n when the index was out of bounds.
*   Fixed GEOS line string closed test.
*   Implemented support for Z and M coordinates in GEOS, SimpleCartesian,
    SimpleMercator, and SimpleSpherical. GEOS and SimpleMercator support Z or
    M but not both at once, because the underlying GEOS library supports only
    3 dimensions. SimpleCartesian and SimpleSpherical can support both at
    once.
*   Implemented parsers and generators for WKT/WKB and EWKT/EWKB in Ruby,
    providing full support for all generally used cases including 3 and 4
    dimensional data and embedded SRIDs. This implementation is used by
    default by all feature implementations except GEOS, which continues to use
    its own internal WKT/WKB implementation unless the Ruby implementation is
    invoked explicitly.


### 0.1.13 / 2010-10-26

*   Reworked the way casting is done. Casting has two dimensions: factory
    casting and type casting, either or both of which can be done at once.
    Implemented a standard casting algorithm to handle these cases, and an
    override mechanism for factories that want to do some of their own
    casting. Removed Factory#cast and Geometry#cast, and implemented a global
    Features::cast entry point instead.
*   All factory and relational methods now perform auto-casting on inputs.
*   Removed the "auto-flattening" behavior of Factory#multi_point,
    Factory#multi_line_string, and Factory#multi_polygon because it seemed
    overkill for factory methods. These methods now just attempt to auto-cast
    the immediate objects.
*   Filled out more test cases for SimpleSpherical.
*   Provided SimpleCartesian as a fallback implementation in case Geos is not
    available. SimpleCartesian is like SimpleSpherical in that some operations
    are not provided, but it is pure ruby and doesn't depend on external
    libraries.
*   Improved feature type checking facilities.
*   Documentation updates.


### 0.1.12 / 2010-10-23

*   API CHANGE: Factory#coerce renamed to Factory#cast. I think this should be
    the final name for this function.
*   Some new tests and a lot of fixes in SimpleMercator and SimpleSpherical.
*   Implemented a few more pieces of SimpleSpherical. Notably,
    LineString#is_simple? (which should now allow LinearRing to work).
*   Classes that included Features::Geometry had their === operator
    erroneously overridden. Fixed.
*   A few more documentation updates.


### 0.1.11 / 2010-10-21

*   API CHANGE: Factory#convert renamed to Factory#coerce.
*   Some implementations that inherit from RGeo::Features::Geometry (e.g. the
    Geography implementations) raised Unimplemented from operator
    implementations because they had aliased the wrong methods. Fixed.
*   Geos coercer didn't properly coerce "contained" elements in a compound
    geometry. Fixed.
*   The SimpleMercator and SimpleSpherical factories failed to properly check
    and coerce inputs into the typed collection methods. Fixed.
*   The options for the SimpleMercator factory were not documented and didn't
    work. Fixed.
*   A bunch of additional test cases and minor fixes for SimpleMercator and
    SimpleSpherical.


### 0.1.10 / 2010-10-19

Initial public release. This release is considered pre-alpha quality and is
being released for experimentation and feedback. We are using it in production
in a limited capacity at GeoPage, but we do not yet recommend general
production deployment because there are a number of known bugs and incomplete
areas, and many features and APIs are still in flux.

Status:

*   GEOS-based Cartesian implementation is tested and should be fairly stable.
*   GeoJSON parsers and generators are tested and should be fairly stable.
*   Parts of SimpleMercator implementation are fairly stable, but test
    coverage of more advanced features is still lacking.
*   SimpleSpherical implementation is under construction and not yet
    available.
*   Rails (ActiveRecord or ActiveModel) integration is pending.
*   Several other integration features, including possible SimpleGeo
    integration, are pending.


Changes since 0.1.9:

*   Eliminated a few (harmless) compiler warnings when compiling the GEOS
    bridge under Ruby 1.9.2 on Snow Leopard.
*   Modified file headers, copyright notices, and README files for public
    release.
*   Changed name from "gp_rgeo" to "rgeo" for public release.


### 0.1.9

This and earlier versions were tested internally at GeoPage, Inc. but not
publicly released.
