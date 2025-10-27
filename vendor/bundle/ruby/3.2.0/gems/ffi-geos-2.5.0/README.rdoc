
= GEOS Ruby Bindings via FFI

== Requirements

* the ffi extension for Ruby.
* GEOS version 3.3.0 or greater. GEOS 3.2.2 and below will work to an extent,
  but some features and methods will be disabled or missing.

We currently test on Travis CI using the current releases of MRI that are
maintained. See `.travis.yml` for a list. We also test against jruby-head.

=== JRuby Notes

Note that versions of JRuby prior to version 1.6.3 have problems in their ffi
implementation when dealing with AutoPointers that can lead to segfaults during
garbage collection.

== Features

ffi-geos supports all of the features found in the binary SWIG-based GEOS
Ruby bindings along with the following enhancements and additions:

* support for prepared geometries via Geos::Geometry#to_prepared.

* an implementation of Geos::STRtree.

* use of GEOS's re-entrant interface for thread-safety.

* new options for controlling WKT output like trim and rounding precision.

* many new methods on geometry types. See below for a list.

* Geos::LineString, Geos::LinearRing, Geos::CoordinateSequence and
  Geos::GeometryCollection and its descendants are now enumerable.

* The aforementioned enumerable classes also define some additional Array-like
  methods such as [] and slice.

* Geos::WkbWriter and Geos::WktWriter have had their constructors extended
  to allow for settings via an options Hash.

* Geos::WkbWriter#write, Geos::WkbWriter#write_hex and Geos::WktWriter#write
  have been enhanced to take options Hashes allowing you to set per-write
  settings.

* Geos::BufferParams class that allows for more extensive Geos::Geometry#buffer
  options.

* Geos::PreparedGeometry class and Geos::Geometry#to_prepared method to
  allow for prepared geometries and more efficient relationship testing.

* Geos::Interrupt module that allows you to interrupt certain calls to the
  GEOS library and perform other work or cancel GEOS calls outright. The
  interruption API was added in GEOS 3.4.0.

* Geos::GeoJSONReader and Geos::GeoJSONWriter support on GEOS 3.10+.

== New Methods and Additions (not exhaustive)

* SRIDs can be copied on many operations. GEOS doesn't usually copy SRIDs
  around, but for the sake of convenience, we do. The default behaviour for
  SRID copying can be set via the Geos.srid_copy_policy= method. The default
  behaviour is to use 0 values as before, but you can optionally allow for
  copying in either a lenient or a strict sort of manner. See the documentation
  for Geos.srid_copy_policy= for details.

* There are many, many new methods added all over the place. Pretty much the
  entire GEOS C API is represented in ffi-geos along with all sorts of useful
  convenience methods and geometry conversion and manipulation methods.

== Thanks

* Daniel Azuma for the testing and JRuby help.

* Christopher Meiklejohn for the bug reporting and PreparedGeometry fix.

* Wayne Meissner for some help with some ffi issues.

* Charlie Savage for the original SWIG-based GEOS bindings implementation and
  some fixes for MinGW.

* Peter M. Goldstein for some JRuby fixes.

== License

This gem is licensed under an MIT-style license. See the +MIT-LICENSE+ file for
details.
