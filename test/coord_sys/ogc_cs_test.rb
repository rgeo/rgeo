# frozen_string_literal: true

# -----------------------------------------------------------------------------
#
# Tests for OGC CS classes
#
# -----------------------------------------------------------------------------

require "test_helper"

class OgcCsTest < Minitest::Test # :nodoc:
  # Handle differences in floating-point output.

  def lenient_regex_for(str)
    Regexp.new(str.gsub(/(\d)\.(\d{10,})/) do
      before = Regexp.last_match(1)
      after = Regexp.last_match(2)[0, 10]
      "#{before}.#{after}\\d*"
    end.gsub(/(\.|\[|\]|\(|\)|\$|\^|\||\+)/) { "\\#{Regexp.last_match(1)}" })
  end

  def test_axis_info_by_value
    obj = RGeo::CoordSys::CS::AxisInfo.create("N", RGeo::CoordSys::CS::AO_NORTH)
    assert_equal("N", obj.name)
    assert_equal(RGeo::CoordSys::CS::AO_NORTH, obj.orientation)
    assert_equal('AXIS["N",NORTH]', obj.to_wkt)
  end

  def test_axis_info_by_name
    obj = RGeo::CoordSys::CS::AxisInfo.create("S", "SOUTH")
    assert_equal("S", obj.name)
    assert_equal(RGeo::CoordSys::CS::AO_SOUTH, obj.orientation)
    assert_equal('AXIS["S",SOUTH]', obj.to_wkt)
    obj2 = RGeo::CoordSys::CS::AxisInfo.create("S", RGeo::CoordSys::CS::AO_SOUTH)
    assert_equal(obj, obj2)
  end

  def test_parameter
    obj = RGeo::CoordSys::CS::ProjectionParameter.create("false_easting", 400_000)
    assert_equal("false_easting", obj.name)
    assert_equal(400_000, obj.value)
    assert_equal('PARAMETER["false_easting",400000.0]', obj.to_wkt)
  end

  def test_towgs84
    obj = RGeo::CoordSys::CS::WGS84ConversionInfo.create(1, 2, 3, 4, 5, 6, 7)
    assert_equal(1, obj.dx)
    assert_equal(2, obj.dy)
    assert_equal(3, obj.dz)
    assert_equal(4, obj.ex)
    assert_equal(5, obj.ey)
    assert_equal(6, obj.ez)
    assert_equal(7, obj.ppm)
    assert_equal("TOWGS84[1.0,2.0,3.0,4.0,5.0,6.0,7.0]", obj.to_wkt)
  end

  def test_unit
    obj = RGeo::CoordSys::CS::Unit.create("metre", 1)
    assert_equal("metre", obj.name)
    assert_equal(1, obj.conversion_factor)
    assert_nil(obj.authority)
    assert_equal('UNIT["metre",1.0]', obj.to_wkt)
  end

  def test_unit_with_authority
    obj = RGeo::CoordSys::CS::Unit.create("metre", 1, "EPSG", 9001)
    assert_equal("metre", obj.name)
    assert_equal(1, obj.conversion_factor)
    assert_equal("EPSG", obj.authority)
    assert_equal("9001", obj.authority_code)
    assert_equal('UNIT["metre",1.0,AUTHORITY["EPSG","9001"]]', obj.to_wkt)
  end

  def test_linear_unit
    obj = RGeo::CoordSys::CS::LinearUnit.create("metre", 1)
    assert_equal(1, obj.meters_per_unit)
    assert_equal('UNIT["metre",1.0]', obj.to_wkt)
  end

  def test_angular_unit
    obj = RGeo::CoordSys::CS::AngularUnit.create("radian", 1)
    assert_equal(1, obj.radians_per_unit)
    assert_equal('UNIT["radian",1.0]', obj.to_wkt)
  end

  def test_prime_meridian
    obj1 = RGeo::CoordSys::CS::AngularUnit.create("radian", 1)
    obj = RGeo::CoordSys::CS::PrimeMeridian.create("Greenwich", obj1, 0, "EPSG", "8901")
    assert_equal("Greenwich", obj.name)
    assert_equal(0, obj.longitude)
    assert_equal('PRIMEM["Greenwich",0.0,AUTHORITY["EPSG","8901"]]', obj.to_wkt)
  end

  def test_create_flattened_sphere
    obj1 = RGeo::CoordSys::CS::LinearUnit.create("metre", 1)
    obj = RGeo::CoordSys::CS::Ellipsoid.create_flattened_sphere("WGS 84", 6_378_137, 298.257223563, obj1, "EPSG", "7030")
    assert_equal("WGS 84", obj.name)
    assert_equal(6_378_137, obj.semi_major_axis)
    assert_in_delta(298.257223563, obj.inverse_flattening, 0.1)
    assert_in_delta(6_356_752.314245, obj.semi_minor_axis, 0.1)
    assert_equal("EPSG", obj.authority)
    assert_equal("7030", obj.authority_code)
    assert_equal('SPHEROID["WGS 84",6378137.0,298.257223563,AUTHORITY["EPSG","7030"]]', obj.to_wkt)
  end

  def test_create_unflattened_sphere
    obj1 = RGeo::CoordSys::CS::LinearUnit.create("metre", 1)
    obj = RGeo::CoordSys::CS::Ellipsoid.create_flattened_sphere("Popular Visualisation Sphere", 6_378_137, 0, obj1, "EPSG", "7059")
    assert_equal("Popular Visualisation Sphere", obj.name)
    assert_equal(6_378_137, obj.semi_major_axis)
    assert_equal(0, obj.inverse_flattening)
    assert_equal(6_378_137, obj.semi_minor_axis)
    assert_equal("EPSG", obj.authority)
    assert_equal("7059", obj.authority_code)
    assert_equal('SPHEROID["Popular Visualisation Sphere",6378137.0,0.0,AUTHORITY["EPSG","7059"]]', obj.to_wkt)
  end

  def test_create_ellipsoid
    obj1 = RGeo::CoordSys::CS::LinearUnit.create("metre", 1)
    obj = RGeo::CoordSys::CS::Ellipsoid.create_ellipsoid("WGS 84", 6_378_137, 6_356_752.314245, obj1, "EPSG", "7030")
    assert_in_delta(298.257223563, obj.inverse_flattening, 0.1)
  end

  def test_create_spherical_ellipsoid
    obj1 = RGeo::CoordSys::CS::LinearUnit.create("metre", 1)
    obj = RGeo::CoordSys::CS::Ellipsoid.create_ellipsoid("Popular Visualisation Sphere", 6_378_137, 6_378_137, obj1, "EPSG", "7059")
    assert_equal(0, obj.inverse_flattening)
  end

  def test_local_datum
    obj = RGeo::CoordSys::CS::LocalDatum.create("Random Local Datum", RGeo::CoordSys::CS::LD_MIN)
    assert_equal("Random Local Datum", obj.name)
    assert_equal(RGeo::CoordSys::CS::LD_MIN, obj.datum_type)
    assert_equal('LOCAL_DATUM["Random Local Datum",10000]', obj.to_wkt)
  end

  def test_local_datum_with_extension
    obj = RGeo::CoordSys::CS::LocalDatum.create("Random Local Datum", RGeo::CoordSys::CS::LD_MIN, nil, nil, nil, nil, nil, foo: :bar)
    assert_equal("bar", obj.extension(:foo))
    assert_nil(obj.extension(:bar))
    assert_equal('LOCAL_DATUM["Random Local Datum",10000,EXTENSION["foo","bar"]]', obj.to_wkt)
  end

  def test_vertical_datum
    obj = RGeo::CoordSys::CS::VerticalDatum.create("Ordnance Datum Newlyn", RGeo::CoordSys::CS::VD_GEOID_MODE_DERIVED, "EPSG", "5101")
    assert_equal("Ordnance Datum Newlyn", obj.name)
    assert_equal(RGeo::CoordSys::CS::VD_GEOID_MODE_DERIVED, obj.datum_type)
    assert_equal("EPSG", obj.authority)
    assert_equal("5101", obj.authority_code)
    assert_equal('VERT_DATUM["Ordnance Datum Newlyn",2005,AUTHORITY["EPSG","5101"]]', obj.to_wkt)
  end

  def test_horizontal_datum
    obj1 = RGeo::CoordSys::CS::LinearUnit.create("metre", 1)
    obj2 = RGeo::CoordSys::CS::Ellipsoid.create_ellipsoid("Popular Visualisation Sphere", 6_378_137, 6_378_137, obj1, "EPSG", "7059")
    obj3 = RGeo::CoordSys::CS::WGS84ConversionInfo.create(0, 0, 0, 0, 0, 0, 0)
    obj = RGeo::CoordSys::CS::HorizontalDatum.create("Popular_Visualisation_Datum", RGeo::CoordSys::CS::HD_GEOCENTRIC, obj2, obj3, "EPSG", "6055")
    assert_equal("Popular_Visualisation_Datum", obj.name)
    assert_equal(RGeo::CoordSys::CS::HD_GEOCENTRIC, obj.datum_type)
    assert_equal("EPSG", obj.authority)
    assert_equal("6055", obj.authority_code)
    assert_equal('DATUM["Popular_Visualisation_Datum",SPHEROID["Popular Visualisation Sphere",6378137.0,0.0,AUTHORITY["EPSG","7059"]],TOWGS84[0.0,0.0,0.0,0.0,0.0,0.0,0.0],AUTHORITY["EPSG","6055"]]', obj.to_wkt)
  end

  def test_projection
    obj = RGeo::CoordSys::CS::Projection.create("Transverse_Mercator", "Transverse_Mercator", [])
    assert_equal("Transverse_Mercator", obj.name)
    assert_equal("Transverse_Mercator", obj.class_name)
    assert_equal(0, obj.num_parameters)
    assert_equal('PROJECTION["Transverse_Mercator"]', obj.to_wkt)
  end

  def test_local_coordinate_system
    obj1 = RGeo::CoordSys::CS::LocalDatum.create("Random Local Datum", RGeo::CoordSys::CS::LD_MIN)
    obj2 = RGeo::CoordSys::CS::LinearUnit.create("metre", 1, "EPSG", 9001)
    obj3 = RGeo::CoordSys::CS::AxisInfo.create("N", RGeo::CoordSys::CS::AO_NORTH)
    obj4 = RGeo::CoordSys::CS::AxisInfo.create("E", RGeo::CoordSys::CS::AO_EAST)
    obj = RGeo::CoordSys::CS::LocalCoordinateSystem.create("My CS", obj1, obj2, [obj3, obj4])
    assert_equal("My CS", obj.name)
    assert_equal(2, obj.dimension)
    assert_equal("Random Local Datum", obj.local_datum.name)
    assert_equal("N", obj.get_axis(0).name)
    assert_equal("E", obj.get_axis(1).name)
    assert_equal("metre", obj.get_units(0).name)
    assert_equal("metre", obj.get_units(1).name)
    assert_equal('LOCAL_CS["My CS",LOCAL_DATUM["Random Local Datum",10000],UNIT["metre",1.0,AUTHORITY["EPSG","9001"]],AXIS["N",NORTH],AXIS["E",EAST]]', obj.to_wkt)
  end

  def test_geocentric_coordinate_system
    obj1 = RGeo::CoordSys::CS::Ellipsoid.create_flattened_sphere("WGS 84", 6_378_137, 298.257223563, nil, "EPSG", "7030")
    obj2 = RGeo::CoordSys::CS::HorizontalDatum.create("World Geodetic System 1984", RGeo::CoordSys::CS::HD_GEOCENTRIC, obj1, nil, "EPSG", "6326")
    obj3 = RGeo::CoordSys::CS::PrimeMeridian.create("Greenwich", nil, 0.0, "EPSG", "8901")
    obj4 = RGeo::CoordSys::CS::LinearUnit.create("m", 1.0)
    obj5 = RGeo::CoordSys::CS::AxisInfo.create("Geocentric X", RGeo::CoordSys::CS::AO_OTHER)
    obj6 = RGeo::CoordSys::CS::AxisInfo.create("Geocentric Y", RGeo::CoordSys::CS::AO_EAST)
    obj7 = RGeo::CoordSys::CS::AxisInfo.create("Geocentric Z", RGeo::CoordSys::CS::AO_NORTH)
    obj = RGeo::CoordSys::CS::GeocentricCoordinateSystem.create("WGS 84 (geocentric)", obj2, obj3, obj4, obj5, obj6, obj7, "EPSG", 4328)
    assert_equal("WGS 84 (geocentric)", obj.name)
    assert_equal(3, obj.dimension)
    assert_equal("World Geodetic System 1984", obj.horizontal_datum.name)
    assert_equal("Greenwich", obj.prime_meridian.name)
    assert_equal("m", obj.linear_unit.name)
    assert_equal("Geocentric X", obj.get_axis(0).name)
    assert_equal("Geocentric Y", obj.get_axis(1).name)
    assert_equal("Geocentric Z", obj.get_axis(2).name)
    assert_equal("m", obj.get_units(0).name)
    assert_equal("m", obj.get_units(1).name)
    assert_equal("m", obj.get_units(2).name)
    assert_equal('GEOCCS["WGS 84 (geocentric)",DATUM["World Geodetic System 1984",SPHEROID["WGS 84",6378137.0,298.257223563,AUTHORITY["EPSG","7030"]],AUTHORITY["EPSG","6326"]],PRIMEM["Greenwich",0.0,AUTHORITY["EPSG","8901"]],UNIT["m",1.0],AXIS["Geocentric X",OTHER],AXIS["Geocentric Y",EAST],AXIS["Geocentric Z",NORTH],AUTHORITY["EPSG","4328"]]', obj.to_wkt)
  end

  def test_vertical_coordinate_system
    obj1 = RGeo::CoordSys::CS::VerticalDatum.create("Ordnance Datum Newlyn", RGeo::CoordSys::CS::VD_GEOID_MODE_DERIVED, "EPSG", 5101)
    obj2 = RGeo::CoordSys::CS::LinearUnit.create("metre", 1, "EPSG", 9001)
    obj3 = RGeo::CoordSys::CS::AxisInfo.create("Up", RGeo::CoordSys::CS::AO_UP)
    obj = RGeo::CoordSys::CS::VerticalCoordinateSystem.create("Newlyn", obj1, obj2, obj3, "EPSG", 5701)
    assert_equal("Newlyn", obj.name)
    assert_equal(1, obj.dimension)
    assert_equal("Ordnance Datum Newlyn", obj.vertical_datum.name)
    assert_equal("metre", obj.vertical_unit.name)
    assert_equal("Up", obj.get_axis(0).name)
    assert_equal("metre", obj.get_units(0).name)
    assert_equal('VERT_CS["Newlyn",VERT_DATUM["Ordnance Datum Newlyn",2005,AUTHORITY["EPSG","5101"]],UNIT["metre",1.0,AUTHORITY["EPSG","9001"]],AXIS["Up",UP],AUTHORITY["EPSG","5701"]]', obj.to_wkt)
  end

  def test_geographic_coordinate_system
    obj1 = RGeo::CoordSys::CS::Ellipsoid.create_flattened_sphere("WGS 84", 6_378_137, 298.257223563, nil, "EPSG", "7030")
    obj2 = RGeo::CoordSys::CS::AngularUnit.create("degree", 0.01745329251994328, "EPSG", 9122)
    obj3 = RGeo::CoordSys::CS::HorizontalDatum.create("WGS_1984", RGeo::CoordSys::CS::HD_GEOCENTRIC, obj1, nil, "EPSG", "6326")
    obj4 = RGeo::CoordSys::CS::PrimeMeridian.create("Greenwich", nil, 0, "EPSG", "8901")
    obj = RGeo::CoordSys::CS::GeographicCoordinateSystem.create("WGS 84", obj2, obj3, obj4, nil, nil, "EPSG", 4326)
    assert_equal("WGS 84", obj.name)
    assert_equal(2, obj.dimension)
    assert_equal("WGS_1984", obj.horizontal_datum.name)
    assert_equal("Greenwich", obj.prime_meridian.name)
    assert_equal("degree", obj.angular_unit.name)
    assert_nil(obj.get_axis(0))
    assert_nil(obj.get_axis(1))
    assert_equal("degree", obj.get_units(0).name)
    assert_equal("degree", obj.get_units(1).name)
    assert_match(lenient_regex_for('GEOGCS["WGS 84",DATUM["WGS_1984",SPHEROID["WGS 84",6378137.0,298.257223563,AUTHORITY["EPSG","7030"]],AUTHORITY["EPSG","6326"]],PRIMEM["Greenwich",0.0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.01745329251994328,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4326"]]'), obj.to_wkt)
  end

  def test_projected_coordinate_system
    obj1 = RGeo::CoordSys::CS::Ellipsoid.create_flattened_sphere("Airy 1830", 6_377_563.396, 299.3249646, nil, "EPSG", "7001")
    obj2 = RGeo::CoordSys::CS::WGS84ConversionInfo.create(375, -111, 431, 0, 0, 0, 0)
    obj3 = RGeo::CoordSys::CS::AngularUnit.create("DMSH", 0.0174532925199433, "EPSG", 9108)
    obj4 = RGeo::CoordSys::CS::HorizontalDatum.create("OSGB_1936", RGeo::CoordSys::CS::HD_CLASSIC, obj1, obj2, "EPSG", "6277")
    obj5 = RGeo::CoordSys::CS::PrimeMeridian.create("Greenwich", nil, 0, "EPSG", "8901")
    obj6 = RGeo::CoordSys::CS::AxisInfo.create("Lat", RGeo::CoordSys::CS::AO_NORTH)
    obj7 = RGeo::CoordSys::CS::AxisInfo.create("Long", RGeo::CoordSys::CS::AO_EAST)
    obj8 = RGeo::CoordSys::CS::GeographicCoordinateSystem.create("OSGB 1936", obj3, obj4, obj5, obj6, obj7, "EPSG", 4277)
    obj9 = RGeo::CoordSys::CS::ProjectionParameter.create("latitude_of_origin", 49)
    obj10 = RGeo::CoordSys::CS::ProjectionParameter.create("central_meridian", -2)
    obj11 = RGeo::CoordSys::CS::ProjectionParameter.create("scale_factor", 0.999601272)
    obj12 = RGeo::CoordSys::CS::ProjectionParameter.create("false_easting", 400_000)
    obj13 = RGeo::CoordSys::CS::ProjectionParameter.create("false_northing", -100_000)
    obj14 = RGeo::CoordSys::CS::Projection.create("Transverse_Mercator", "Transverse_Mercator", [obj9, obj10, obj11, obj12, obj13])
    obj15 = RGeo::CoordSys::CS::LinearUnit.create("metre", 1, "EPSG", 9001)
    obj16 = RGeo::CoordSys::CS::AxisInfo.create("E", RGeo::CoordSys::CS::AO_EAST)
    obj17 = RGeo::CoordSys::CS::AxisInfo.create("N", RGeo::CoordSys::CS::AO_NORTH)
    obj = RGeo::CoordSys::CS::ProjectedCoordinateSystem.create("OSGB 1936 / British National Grid", obj8, obj14, obj15, obj16, obj17, "EPSG", 27_700)
    assert_equal("OSGB 1936 / British National Grid", obj.name)
    assert_equal(2, obj.dimension)
    assert_equal("OSGB_1936", obj.horizontal_datum.name)
    assert_equal("OSGB 1936", obj.geographic_coordinate_system.name)
    assert_equal("Transverse_Mercator", obj.projection.name)
    assert_equal(5, obj.projection.num_parameters)
    assert_equal("latitude_of_origin", obj.projection.get_parameter(0).name)
    assert_equal(49, obj.projection.get_parameter(0).value)
    assert_equal("false_northing", obj.projection.get_parameter(4).name)
    assert_equal(-100_000, obj.projection.get_parameter(4).value)
    assert_equal("metre", obj.linear_unit.name)
    assert_equal("E", obj.get_axis(0).name)
    assert_equal("N", obj.get_axis(1).name)
    assert_equal("metre", obj.get_units(0).name)
    assert_equal("metre", obj.get_units(1).name)
    assert_equal('PROJCS["OSGB 1936 / British National Grid",GEOGCS["OSGB 1936",DATUM["OSGB_1936",SPHEROID["Airy 1830",6377563.396,299.3249646,AUTHORITY["EPSG","7001"]],TOWGS84[375.0,-111.0,431.0,0.0,0.0,0.0,0.0],AUTHORITY["EPSG","6277"]],PRIMEM["Greenwich",0.0,AUTHORITY["EPSG","8901"]],UNIT["DMSH",0.0174532925199433,AUTHORITY["EPSG","9108"]],AXIS["Lat",NORTH],AXIS["Long",EAST],AUTHORITY["EPSG","4277"]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",49.0],PARAMETER["central_meridian",-2.0],PARAMETER["scale_factor",0.999601272],PARAMETER["false_easting",400000.0],PARAMETER["false_northing",-100000.0],UNIT["metre",1.0,AUTHORITY["EPSG","9001"]],AXIS["E",EAST],AXIS["N",NORTH],AUTHORITY["EPSG","27700"]]', obj.to_wkt)
  end

  def test_parse_epsg_6055
    input = 'DATUM["Popular_Visualisation_Datum",SPHEROID["Popular Visualisation Sphere",6378137.0,0.0,AUTHORITY["EPSG","7059"]],TOWGS84[0.0,0.0,0.0,0.0,0.0,0.0,0.0],AUTHORITY["EPSG","6055"]]'
    obj = RGeo::CoordSys::CS.create_from_wkt(input)
    assert_kind_of(RGeo::CoordSys::CS::HorizontalDatum, obj)
    assert_equal("Popular_Visualisation_Datum", obj.name)
    assert_equal(RGeo::CoordSys::CS::HD_GEOCENTRIC, obj.datum_type)
    assert_equal("EPSG", obj.authority)
    assert_equal("6055", obj.authority_code)
    assert_equal("Popular Visualisation Sphere", obj.ellipsoid.name)
    assert_equal(6_378_137, obj.ellipsoid.semi_major_axis)
    assert_equal(0, obj.ellipsoid.inverse_flattening)
    assert_equal(6_378_137, obj.ellipsoid.semi_minor_axis)
    assert_equal("EPSG", obj.ellipsoid.authority)
    assert_equal("7059", obj.ellipsoid.authority_code)
    assert_equal(0, obj.wgs84_parameters.dx)
    assert_equal(input, obj.to_wkt)
  end

  def test_parse_epsg_7405
    input = 'COMPD_CS["OSGB36 / British National Grid + ODN",PROJCS["OSGB 1936 / British National Grid",GEOGCS["OSGB 1936",DATUM["OSGB 1936",SPHEROID["Airy 1830",6377563.396,299.3249646,AUTHORITY["EPSG","7001"]],TOWGS84[446.448,-125.157,542.06,0.15,0.247,0.842,-4.2261596151967575],AUTHORITY["EPSG","6277"]],PRIMEM["Greenwich",0.0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.017453292519943295],AXIS["Geodetic latitude",NORTH],AXIS["Geodetic longitude",EAST],AUTHORITY["EPSG","4277"]],PROJECTION["Transverse Mercator",AUTHORITY["EPSG","9807"]],PARAMETER["central_meridian",-2.0],PARAMETER["latitude_of_origin",49.0],PARAMETER["scale_factor",0.9996012717],PARAMETER["false_easting",400000.0],PARAMETER["false_northing",-100000.0],UNIT["m",1.0],AXIS["Easting",EAST],AXIS["Northing",NORTH],AUTHORITY["EPSG","27700"]],VERT_CS["Newlyn",VERT_DATUM["Ordnance Datum Newlyn",2005,AUTHORITY["EPSG","5101"]],UNIT["m",1.0],AXIS["Gravity-related height",UP],AUTHORITY["EPSG","5701"]],AUTHORITY["EPSG","7405"]]'
    obj = RGeo::CoordSys::CS.create_from_wkt(input)
    assert_kind_of(RGeo::CoordSys::CS::CompoundCoordinateSystem, obj)
    assert_kind_of(RGeo::CoordSys::CS::ProjectedCoordinateSystem, obj.head)
    assert_kind_of(RGeo::CoordSys::CS::VerticalCoordinateSystem, obj.tail)
    assert_equal(3, obj.dimension)
    assert_match(lenient_regex_for(input), obj.to_wkt)
  end

  def test_parse_local_datum_with_extension
    input = 'LOCAL_DATUM["Random Local Datum",10000,EXTENSION["foo","bar"]]'
    obj = RGeo::CoordSys::CS.create_from_wkt(input)
    assert_kind_of(RGeo::CoordSys::CS::LocalDatum, obj)
    assert_equal("bar", obj.extension(:foo))
    assert_nil(obj.extension(:bar))
    assert_equal(input, obj.to_wkt)
  end

  def test_marshal_roundtrip
    input = 'COMPD_CS["OSGB36 / British National Grid + ODN",PROJCS["OSGB 1936 / British National Grid",GEOGCS["OSGB 1936",DATUM["OSGB 1936",SPHEROID["Airy 1830",6377563.396,299.3249646,AUTHORITY["EPSG","7001"]],TOWGS84[446.448,-125.157,542.06,0.15,0.247,0.842,-4.2261596151967575],AUTHORITY["EPSG","6277"]],PRIMEM["Greenwich",0.0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.017453292519943295],AXIS["Geodetic latitude",NORTH],AXIS["Geodetic longitude",EAST],AUTHORITY["EPSG","4277"]],PROJECTION["Transverse Mercator",AUTHORITY["EPSG","9807"]],PARAMETER["central_meridian",-2.0],PARAMETER["latitude_of_origin",49.0],PARAMETER["scale_factor",0.9996012717],PARAMETER["false_easting",400000.0],PARAMETER["false_northing",-100000.0],UNIT["m",1.0],AXIS["Easting",EAST],AXIS["Northing",NORTH],AUTHORITY["EPSG","27700"]],VERT_CS["Newlyn",VERT_DATUM["Ordnance Datum Newlyn",2005,AUTHORITY["EPSG","5101"]],UNIT["m",1.0],AXIS["Gravity-related height",UP],AUTHORITY["EPSG","5701"]],AUTHORITY["EPSG","7405"]]'
    obj1 = RGeo::CoordSys::CS.create_from_wkt(input)
    dump = Marshal.dump(obj1)
    obj2 = Marshal.load(dump)
    assert_equal(obj1, obj2)
  end

  def test_yaml_roundtrip
    input = 'COMPD_CS["OSGB36 / British National Grid + ODN",PROJCS["OSGB 1936 / British National Grid",GEOGCS["OSGB 1936",DATUM["OSGB 1936",SPHEROID["Airy 1830",6377563.396,299.3249646,AUTHORITY["EPSG","7001"]],TOWGS84[446.448,-125.157,542.06,0.15,0.247,0.842,-4.2261596151967575],AUTHORITY["EPSG","6277"]],PRIMEM["Greenwich",0.0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.017453292519943295],AXIS["Geodetic latitude",NORTH],AXIS["Geodetic longitude",EAST],AUTHORITY["EPSG","4277"]],PROJECTION["Transverse Mercator",AUTHORITY["EPSG","9807"]],PARAMETER["central_meridian",-2.0],PARAMETER["latitude_of_origin",49.0],PARAMETER["scale_factor",0.9996012717],PARAMETER["false_easting",400000.0],PARAMETER["false_northing",-100000.0],UNIT["m",1.0],AXIS["Easting",EAST],AXIS["Northing",NORTH],AUTHORITY["EPSG","27700"]],VERT_CS["Newlyn",VERT_DATUM["Ordnance Datum Newlyn",2005,AUTHORITY["EPSG","5101"]],UNIT["m",1.0],AXIS["Gravity-related height",UP],AUTHORITY["EPSG","5701"]],AUTHORITY["EPSG","7405"]]'
    obj1 = RGeo::CoordSys::CS.create_from_wkt(input)
    dump = Psych.dump(obj1)
    obj2 = Psych.load(dump)
    assert_equal(obj1, obj2)
  end
end
