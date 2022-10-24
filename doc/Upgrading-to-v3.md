# Upgrading to RGeo Version 3.0

Here's a checklist of things to change when upgrading to RGeo 3.0. For a comprehensive list of changes, see [History.md](../History.md).

* Remove `uses_lenient_assertions` and `uses_lenient_multipolygon_assertions` flags from factory creation.
* If your app requires predicate or analysis methods (ex. `contains?` and `area`) to be called on invalid geometries, you may want to consider using the `unsafe_*` variants of those methods to skip the validity check. See [Geometry-Validity.md](Geometry-Validity.md) for more detail.
* Remove `boundary` calls on `GeometryCollections`
* Remove all `is_*?` methods and replace with the `*?` versions.
* Remove `SRSDatabase` usage
* Change `proj4` options to `coord_sys` or use the EPSG SRID in the `srid` option for factory creation.
* Rename instances `Geographic::Proj4Projector` to `Geographic::Projector` and use `coord_sys` instead of `proj4` during creation.