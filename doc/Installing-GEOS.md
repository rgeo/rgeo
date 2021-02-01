# Installing GEOS

The best way to use RGeo is with [GEOS] installed. It is a fairly simple process, and this guide will help you walk through the installation.

## What is [GEOS]?

[GEOS] is a C++ port of the [Java JTS Topology Suite ][jts] which is an implementation of the [OGC SFS][SFS]. Essentially, they provide a convenient way to work with geometry data.

## Why do I need it, since I use RGeo?

RGeo has implemented a lot of the specs in the [SFS], however, the [GEOS] library has many more features. Moreover, the C extension is much faster than pure Ruby implementations. Here are some benchmarks for reference:

```ruby
# frozen_string_literal: true

require "benchmark/ips"
require "net/http"
require "rgeo"
require "rgeo-geojson"

# Install GEOS to run this benchmark.
exit 1 unless RGeo::Geos.capi_supported?

# https://github.com/gregoiredavid/france-geojson/blob/master/departements/38-isere/departement-38-isere.geojson
geojson = Net::HTTP.get(URI("https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/departements/38-isere/departement-38-isere.geojson"))

ffi_factory   = RGeo::Cartesian.preferred_factory(native_interface: :ffi)
capi_factory  = RGeo::Cartesian.preferred_factory
ruby_factory  = RGeo::Cartesian.simple_factory
ffi_geometry  = RGeo::GeoJSON.decode(geojson, geo_factory: ffi_factory).geometry
capi_geometry = RGeo::GeoJSON.decode(geojson, geo_factory: capi_factory).geometry
ruby_geometry = RGeo::GeoJSON.decode(geojson, geo_factory: ruby_factory).geometry
ffi_point     = ffi_factory.point(5.72662, 45.18203)
capi_point    = capi_factory.point(5.72662, 45.18203)
ruby_point    = ruby_factory.point(5.72662, 45.18203)

Benchmark.ips do |x|
  x.report("with CAPI GEOS") { capi_geometry.contains?(capi_point) }
  x.report("with FFI GEOS") { ffi_geometry.contains?(ffi_point) }
  x.report("simple ruby") { ruby_geometry.contains?(ruby_point) }

  x.compare!
end
```

<details>

<summary> Result for a MacBook pro 1,4 GHz Quad-Core Intel Core i5 </summary>


<!-- Mixing markdown and html syntax renders poorly with yard. -->
<pre class="code">
Warming up --------------------------------------
      with CAPI GEOS   567.300k i/100ms
       with FFI GEOS    73.764k i/100ms
         simple ruby   101.000  i/100ms
Calculating -------------------------------------
      with CAPI GEOS      5.671M (± 0.9%) i/s -     28.365M in   5.002353s
       with FFI GEOS    732.590k (± 1.7%) i/s -      3.688M in   5.035920s
         simple ruby    963.703  (± 4.9%) i/s -      4.848k in   5.043617s

Comparison:
      with CAPI GEOS:  5670783.7 i/s
       with FFI GEOS:   732589.6 i/s - 7.74x  (± 0.00) slower
         simple ruby:      963.7 i/s - 5884.37x  (± 0.00) slower
</pre>

</details>

## How do I install GEOS ?

The easiest way is to use the package manager on your OS.

```bash
# Mac OS
brew install geos
# Ubuntu
apt-get install libgeos-dev
...
```

You can also get binaries or build from source directly. See https://trac.osgeo.org/geos#Binaries for more possibilities.

You can then check in an irb session that it is correctly binded to your `rgeo` gem:

```ruby
require "rgeo"

puts "Yay" if RGeo::Geos.capi_supported?
```

If you need to install it on heroku, [there is a dedicated documentation](https://github.com/rgeo/rgeo/blob/master/doc/Enable-GEOS-and-Proj4-on-Heroku.md).

[geos]: https://trac.osgeo.org/geos
[jts]: https://www.tsusiatsoftware.net/jts/main.html
[SFS]: https://www.ogc.org/standards/sfa
