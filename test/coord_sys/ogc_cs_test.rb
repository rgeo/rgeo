# -----------------------------------------------------------------------------
#
# Tests for OGC CS classes
#
# -----------------------------------------------------------------------------

require "test/unit"
require "rgeo"

module RGeo
  module Tests # :nodoc:
    module CoordSys # :nodoc:
      class TestOgcCs < ::Test::Unit::TestCase # :nodoc:
        # Handle differences in floating-point output.

        def _lenient_regex_for(str_)
          ::Regexp.new(str_.gsub(/(\d)\.(\d{10,})/) do |_m_|
            before_ = Regexp.last_match(1)
            after_ = Regexp.last_match(2)[0, 10]
            "#{before_}.#{after_}\\d*"
          end.gsub(/(\.|\[|\]|\(|\)|\$|\^|\||\+)/) { |_m_| "\\#{Regexp.last_match(1)}" })
        end

        def test_axis_info_by_value
          obj_ = ::RGeo::CoordSys::CS::AxisInfo.create("N", ::RGeo::CoordSys::CS::AO_NORTH)
          assert_equal("N", obj_.name)
          assert_equal(::RGeo::CoordSys::CS::AO_NORTH, obj_.orientation)
          assert_equal('AXIS["N",NORTH]', obj_.to_wkt)
        end

        def test_axis_info_by_name
          obj_ = ::RGeo::CoordSys::CS::AxisInfo.create("S", "SOUTH")
          assert_equal("S", obj_.name)
          assert_equal(::RGeo::CoordSys::CS::AO_SOUTH, obj_.orientation)
          assert_equal('AXIS["S",SOUTH]', obj_.to_wkt)
          obj2_ = ::RGeo::CoordSys::CS::AxisInfo.create("S", ::RGeo::CoordSys::CS::AO_SOUTH)
          assert_equal(obj_, obj2_)
        end

        def test_parameter
          obj_ = ::RGeo::CoordSys::CS::ProjectionParameter.create("false_easting", 400_000)
          assert_equal("false_easting", obj_.name)
          assert_equal(400_000, obj_.value)
          assert_equal('PARAMETER["false_easting",400000.0]', obj_.to_wkt)
        end

        def test_towgs84
          obj_ = ::RGeo::CoordSys::CS::WGS84ConversionInfo.create(1, 2, 3, 4, 5, 6, 7)
          assert_equal(1, obj_.dx)
          assert_equal(2, obj_.dy)
          assert_equal(3, obj_.dz)
          assert_equal(4, obj_.ex)
          assert_equal(5, obj_.ey)
          assert_equal(6, obj_.ez)
          assert_equal(7, obj_.ppm)
          assert_equal("TOWGS84[1.0,2.0,3.0,4.0,5.0,6.0,7.0]", obj_.to_wkt)
        end

        def test_unit
          obj_ = ::RGeo::CoordSys::CS::Unit.create("metre", 1)
          assert_equal("metre", obj_.name)
          assert_equal(1, obj_.conversion_factor)
          assert_nil(obj_.authority)
          assert_equal('UNIT["metre",1.0]', obj_.to_wkt)
        end

        def test_unit_with_authority
          obj_ = ::RGeo::CoordSys::CS::Unit.create("metre", 1, "EPSG", 9001)
          assert_equal("metre", obj_.name)
          assert_equal(1, obj_.conversion_factor)
          assert_equal("EPSG", obj_.authority)
          assert_equal("9001", obj_.authority_code)
          assert_equal('UNIT["metre",1.0,AUTHORITY["EPSG","9001"]]', obj_.to_wkt)
        end

        def test_linear_unit
          obj_ = ::RGeo::CoordSys::CS::LinearUnit.create("metre", 1)
          assert_equal(1, obj_.meters_per_unit)
          assert_equal('UNIT["metre",1.0]', obj_.to_wkt)
        end

        def test_angular_unit
          obj_ = ::RGeo::CoordSys::CS::AngularUnit.create("radian", 1)
          assert_equal(1, obj_.radians_per_unit)
          assert_equal('UNIT["radian",1.0]', obj_.to_wkt)
        end

        def test_prime_meridian
          obj1_ = ::RGeo::CoordSys::CS::AngularUnit.create("radian", 1)
          obj_ = ::RGeo::CoordSys::CS::PrimeMeridian.create("Greenwich", obj1_, 0, "EPSG", "8901")
          assert_equal("Greenwich", obj_.name)
          assert_equal(0, obj_.longitude)
          assert_equal('PRIMEM["Greenwich",0.0,AUTHORITY["EPSG","8901"]]', obj_.to_wkt)
        end

        def test_create_flattened_sphere
          obj1_ = ::RGeo::CoordSys::CS::LinearUnit.create("metre", 1)
          obj_ = ::RGeo::CoordSys::CS::Ellipsoid.create_flattened_sphere("WGS 84", 6_378_137, 298.257223563, obj1_, "EPSG", "7030")
          assert_equal("WGS 84", obj_.name)
          assert_equal(6_378_137, obj_.semi_major_axis)
          assert_in_delta(298.257223563, obj_.inverse_flattening, 0.1)
          assert_in_delta(6_356_752.314245, obj_.semi_minor_axis, 0.1)
          assert_equal("EPSG", obj_.authority)
          assert_equal("7030", obj_.authority_code)
          assert_equal('SPHEROID["WGS 84",6378137.0,298.257223563,AUTHORITY["EPSG","7030"]]', obj_.to_wkt)
        end

        def test_create_unflattened_sphere
          obj1_ = ::RGeo::CoordSys::CS::LinearUnit.create("metre", 1)
          obj_ = ::RGeo::CoordSys::CS::Ellipsoid.create_flattened_sphere("Popular Visualisation Sphere", 6_378_137, 0, obj1_, "EPSG", "7059")
          assert_equal("Popular Visualisation Sphere", obj_.name)
          assert_equal(6_378_137, obj_.semi_major_axis)
          assert_equal(0, obj_.inverse_flattening)
          assert_equal(6_378_137, obj_.semi_minor_axis)
          assert_equal("EPSG", obj_.authority)
          assert_equal("7059", obj_.authority_code)
          assert_equal('SPHEROID["Popular Visualisation Sphere",6378137.0,0.0,AUTHORITY["EPSG","7059"]]', obj_.to_wkt)
        end

        def test_create_ellipsoid
          obj1_ = ::RGeo::CoordSys::CS::LinearUnit.create("metre", 1)
          obj_ = ::RGeo::CoordSys::CS::Ellipsoid.create_ellipsoid("WGS 84", 6_378_137, 6_356_752.314245, obj1_, "EPSG", "7030")
          assert_in_delta(298.257223563, obj_.inverse_flattening, 0.1)
        end

        def test_create_spherical_ellipsoid
          obj1_ = ::RGeo::CoordSys::CS::LinearUnit.create("metre", 1)
          obj_ = ::RGeo::CoordSys::CS::Ellipsoid.create_ellipsoid("Popular Visualisation Sphere", 6_378_137, 6_378_137, obj1_, "EPSG", "7059")
          assert_equal(0, obj_.inverse_flattening)
        end

        def test_local_datum
          obj_ = ::RGeo::CoordSys::CS::LocalDatum.create("Random Local Datum", ::RGeo::CoordSys::CS::LD_MIN)
          assert_equal("Random Local Datum", obj_.name)
          assert_equal(::RGeo::CoordSys::CS::LD_MIN, obj_.datum_type)
          assert_equal('LOCAL_DATUM["Random Local Datum",10000]', obj_.to_wkt)
        end

        def test_local_datum_with_extension
          obj_ = ::RGeo::CoordSys::CS::LocalDatum.create("Random Local Datum", ::RGeo::CoordSys::CS::LD_MIN, nil, nil, nil, nil, nil, foo: :bar)
          assert_equal("bar", obj_.extension(:foo))
          assert_nil(obj_.extension(:bar))
          assert_equal('LOCAL_DATUM["Random Local Datum",10000,EXTENSION["foo","bar"]]', obj_.to_wkt)
        end

        def test_vertical_datum
          obj_ = ::RGeo::CoordSys::CS::VerticalDatum.create("Ordnance Datum Newlyn", ::RGeo::CoordSys::CS::VD_GEOID_MODE_DERIVED, "EPSG", "5101")
          assert_equal("Ordnance Datum Newlyn", obj_.name)
          assert_equal(::RGeo::CoordSys::CS::VD_GEOID_MODE_DERIVED, obj_.datum_type)
          assert_equal("EPSG", obj_.authority)
          assert_equal("5101", obj_.authority_code)
          assert_equal('VERT_DATUM["Ordnance Datum Newlyn",2005,AUTHORITY["EPSG","5101"]]', obj_.to_wkt)
        end

        def test_horizontal_datum
          obj1_ = ::RGeo::CoordSys::CS::LinearUnit.create("metre", 1)
          obj2_ = ::RGeo::CoordSys::CS::Ellipsoid.create_ellipsoid("Popular Visualisation Sphere", 6_378_137, 6_378_137, obj1_, "EPSG", "7059")
          obj3_ = ::RGeo::CoordSys::CS::WGS84ConversionInfo.create(0, 0, 0, 0, 0, 0, 0)
          obj_ = ::RGeo::CoordSys::CS::HorizontalDatum.create("Popular_Visualisation_Datum", ::RGeo::CoordSys::CS::HD_GEOCENTRIC, obj2_, obj3_, "EPSG", "6055")
          assert_equal("Popular_Visualisation_Datum", obj_.name)
          assert_equal(::RGeo::CoordSys::CS::HD_GEOCENTRIC, obj_.datum_type)
          assert_equal("EPSG", obj_.authority)
          assert_equal("6055", obj_.authority_code)
          assert_equal('DATUM["Popular_Visualisation_Datum",SPHEROID["Popular Visualisation Sphere",6378137.0,0.0,AUTHORITY["EPSG","7059"]],TOWGS84[0.0,0.0,0.0,0.0,0.0,0.0,0.0],AUTHORITY["EPSG","6055"]]', obj_.to_wkt)
        end

        def test_projection
          obj_ = ::RGeo::CoordSys::CS::Projection.create("Transverse_Mercator", "Transverse_Mercator", [])
          assert_equal("Transverse_Mercator", obj_.name)
          assert_equal("Transverse_Mercator", obj_.class_name)
          assert_equal(0, obj_.num_parameters)
          assert_equal('PROJECTION["Transverse_Mercator"]', obj_.to_wkt)
        end

        def test_local_coordinate_system
          obj1_ = ::RGeo::CoordSys::CS::LocalDatum.create("Random Local Datum", ::RGeo::CoordSys::CS::LD_MIN)
          obj2_ = ::RGeo::CoordSys::CS::LinearUnit.create("metre", 1, "EPSG", 9001)
          obj3_ = ::RGeo::CoordSys::CS::AxisInfo.create("N", ::RGeo::CoordSys::CS::AO_NORTH)
          obj4_ = ::RGeo::CoordSys::CS::AxisInfo.create("E", ::RGeo::CoordSys::CS::AO_EAST)
          obj_ = ::RGeo::CoordSys::CS::LocalCoordinateSystem.create("My CS", obj1_, obj2_, [obj3_, obj4_])
          assert_equal("My CS", obj_.name)
          assert_equal(2, obj_.dimension)
          assert_equal("Random Local Datum", obj_.local_datum.name)
          assert_equal("N", obj_.get_axis(0).name)
          assert_equal("E", obj_.get_axis(1).name)
          assert_equal("metre", obj_.get_units(0).name)
          assert_equal("metre", obj_.get_units(1).name)
          assert_equal('LOCAL_CS["My CS",LOCAL_DATUM["Random Local Datum",10000],UNIT["metre",1.0,AUTHORITY["EPSG","9001"]],AXIS["N",NORTH],AXIS["E",EAST]]', obj_.to_wkt)
        end

        def test_geocentric_coordinate_system
          obj1_ = ::RGeo::CoordSys::CS::Ellipsoid.create_flattened_sphere("WGS 84", 6_378_137, 298.257223563, nil, "EPSG", "7030")
          obj2_ = ::RGeo::CoordSys::CS::HorizontalDatum.create("World Geodetic System 1984", ::RGeo::CoordSys::CS::HD_GEOCENTRIC, obj1_, nil, "EPSG", "6326")
          obj3_ = ::RGeo::CoordSys::CS::PrimeMeridian.create("Greenwich", nil, 0.0, "EPSG", "8901")
          obj4_ = ::RGeo::CoordSys::CS::LinearUnit.create("m", 1.0)
          obj5_ = ::RGeo::CoordSys::CS::AxisInfo.create("Geocentric X", ::RGeo::CoordSys::CS::AO_OTHER)
          obj6_ = ::RGeo::CoordSys::CS::AxisInfo.create("Geocentric Y", ::RGeo::CoordSys::CS::AO_EAST)
          obj7_ = ::RGeo::CoordSys::CS::AxisInfo.create("Geocentric Z", ::RGeo::CoordSys::CS::AO_NORTH)
          obj_ = ::RGeo::CoordSys::CS::GeocentricCoordinateSystem.create("WGS 84 (geocentric)", obj2_, obj3_, obj4_, obj5_, obj6_, obj7_, "EPSG", 4328)
          assert_equal("WGS 84 (geocentric)", obj_.name)
          assert_equal(3, obj_.dimension)
          assert_equal("World Geodetic System 1984", obj_.horizontal_datum.name)
          assert_equal("Greenwich", obj_.prime_meridian.name)
          assert_equal("m", obj_.linear_unit.name)
          assert_equal("Geocentric X", obj_.get_axis(0).name)
          assert_equal("Geocentric Y", obj_.get_axis(1).name)
          assert_equal("Geocentric Z", obj_.get_axis(2).name)
          assert_equal("m", obj_.get_units(0).name)
          assert_equal("m", obj_.get_units(1).name)
          assert_equal("m", obj_.get_units(2).name)
          assert_equal('GEOCCS["WGS 84 (geocentric)",DATUM["World Geodetic System 1984",SPHEROID["WGS 84",6378137.0,298.257223563,AUTHORITY["EPSG","7030"]],AUTHORITY["EPSG","6326"]],PRIMEM["Greenwich",0.0,AUTHORITY["EPSG","8901"]],UNIT["m",1.0],AXIS["Geocentric X",OTHER],AXIS["Geocentric Y",EAST],AXIS["Geocentric Z",NORTH],AUTHORITY["EPSG","4328"]]', obj_.to_wkt)
        end

        def test_vertical_coordinate_system
          obj1_ = ::RGeo::CoordSys::CS::VerticalDatum.create("Ordnance Datum Newlyn", ::RGeo::CoordSys::CS::VD_GEOID_MODE_DERIVED, "EPSG", 5101)
          obj2_ = ::RGeo::CoordSys::CS::LinearUnit.create("metre", 1, "EPSG", 9001)
          obj3_ = ::RGeo::CoordSys::CS::AxisInfo.create("Up", ::RGeo::CoordSys::CS::AO_UP)
          obj_ = ::RGeo::CoordSys::CS::VerticalCoordinateSystem.create("Newlyn", obj1_, obj2_, obj3_, "EPSG", 5701)
          assert_equal("Newlyn", obj_.name)
          assert_equal(1, obj_.dimension)
          assert_equal("Ordnance Datum Newlyn", obj_.vertical_datum.name)
          assert_equal("metre", obj_.vertical_unit.name)
          assert_equal("Up", obj_.get_axis(0).name)
          assert_equal("metre", obj_.get_units(0).name)
          assert_equal('VERT_CS["Newlyn",VERT_DATUM["Ordnance Datum Newlyn",2005,AUTHORITY["EPSG","5101"]],UNIT["metre",1.0,AUTHORITY["EPSG","9001"]],AXIS["Up",UP],AUTHORITY["EPSG","5701"]]', obj_.to_wkt)
        end

        def test_geographic_coordinate_system
          obj1_ = ::RGeo::CoordSys::CS::Ellipsoid.create_flattened_sphere("WGS 84", 6_378_137, 298.257223563, nil, "EPSG", "7030")
          obj2_ = ::RGeo::CoordSys::CS::AngularUnit.create("degree", 0.01745329251994328, "EPSG", 9122)
          obj3_ = ::RGeo::CoordSys::CS::HorizontalDatum.create("WGS_1984", ::RGeo::CoordSys::CS::HD_GEOCENTRIC, obj1_, nil, "EPSG", "6326")
          obj4_ = ::RGeo::CoordSys::CS::PrimeMeridian.create("Greenwich", nil, 0, "EPSG", "8901")
          obj_ = ::RGeo::CoordSys::CS::GeographicCoordinateSystem.create("WGS 84", obj2_, obj3_, obj4_, nil, nil, "EPSG", 4326)
          assert_equal("WGS 84", obj_.name)
          assert_equal(2, obj_.dimension)
          assert_equal("WGS_1984", obj_.horizontal_datum.name)
          assert_equal("Greenwich", obj_.prime_meridian.name)
          assert_equal("degree", obj_.angular_unit.name)
          assert_nil(obj_.get_axis(0))
          assert_nil(obj_.get_axis(1))
          assert_equal("degree", obj_.get_units(0).name)
          assert_equal("degree", obj_.get_units(1).name)
          assert_match(_lenient_regex_for('GEOGCS["WGS 84",DATUM["WGS_1984",SPHEROID["WGS 84",6378137.0,298.257223563,AUTHORITY["EPSG","7030"]],AUTHORITY["EPSG","6326"]],PRIMEM["Greenwich",0.0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.01745329251994328,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4326"]]'), obj_.to_wkt)
        end

        def test_projected_coordinate_system
          obj1_ = ::RGeo::CoordSys::CS::Ellipsoid.create_flattened_sphere("Airy 1830", 6_377_563.396, 299.3249646, nil, "EPSG", "7001")
          obj2_ = ::RGeo::CoordSys::CS::WGS84ConversionInfo.create(375, -111, 431, 0, 0, 0, 0)
          obj3_ = ::RGeo::CoordSys::CS::AngularUnit.create("DMSH", 0.0174532925199433, "EPSG", 9108)
          obj4_ = ::RGeo::CoordSys::CS::HorizontalDatum.create("OSGB_1936", ::RGeo::CoordSys::CS::HD_CLASSIC, obj1_, obj2_, "EPSG", "6277")
          obj5_ = ::RGeo::CoordSys::CS::PrimeMeridian.create("Greenwich", nil, 0, "EPSG", "8901")
          obj6_ = ::RGeo::CoordSys::CS::AxisInfo.create("Lat", ::RGeo::CoordSys::CS::AO_NORTH)
          obj7_ = ::RGeo::CoordSys::CS::AxisInfo.create("Long", ::RGeo::CoordSys::CS::AO_EAST)
          obj8_ = ::RGeo::CoordSys::CS::GeographicCoordinateSystem.create("OSGB 1936", obj3_, obj4_, obj5_, obj6_, obj7_, "EPSG", 4277)
          obj9_ = ::RGeo::CoordSys::CS::ProjectionParameter.create("latitude_of_origin", 49)
          obj10_ = ::RGeo::CoordSys::CS::ProjectionParameter.create("central_meridian", -2)
          obj11_ = ::RGeo::CoordSys::CS::ProjectionParameter.create("scale_factor", 0.999601272)
          obj12_ = ::RGeo::CoordSys::CS::ProjectionParameter.create("false_easting", 400_000)
          obj13_ = ::RGeo::CoordSys::CS::ProjectionParameter.create("false_northing", -100_000)
          obj14_ = ::RGeo::CoordSys::CS::Projection.create("Transverse_Mercator", "Transverse_Mercator", [obj9_, obj10_, obj11_, obj12_, obj13_])
          obj15_ = ::RGeo::CoordSys::CS::LinearUnit.create("metre", 1, "EPSG", 9001)
          obj16_ = ::RGeo::CoordSys::CS::AxisInfo.create("E", ::RGeo::CoordSys::CS::AO_EAST)
          obj17_ = ::RGeo::CoordSys::CS::AxisInfo.create("N", ::RGeo::CoordSys::CS::AO_NORTH)
          obj_ = ::RGeo::CoordSys::CS::ProjectedCoordinateSystem.create("OSGB 1936 / British National Grid", obj8_, obj14_, obj15_, obj16_, obj17_, "EPSG", 27_700)
          assert_equal("OSGB 1936 / British National Grid", obj_.name)
          assert_equal(2, obj_.dimension)
          assert_equal("OSGB_1936", obj_.horizontal_datum.name)
          assert_equal("OSGB 1936", obj_.geographic_coordinate_system.name)
          assert_equal("Transverse_Mercator", obj_.projection.name)
          assert_equal(5, obj_.projection.num_parameters)
          assert_equal("latitude_of_origin", obj_.projection.get_parameter(0).name)
          assert_equal(49, obj_.projection.get_parameter(0).value)
          assert_equal("false_northing", obj_.projection.get_parameter(4).name)
          assert_equal(-100_000, obj_.projection.get_parameter(4).value)
          assert_equal("metre", obj_.linear_unit.name)
          assert_equal("E", obj_.get_axis(0).name)
          assert_equal("N", obj_.get_axis(1).name)
          assert_equal("metre", obj_.get_units(0).name)
          assert_equal("metre", obj_.get_units(1).name)
          assert_equal('PROJCS["OSGB 1936 / British National Grid",GEOGCS["OSGB 1936",DATUM["OSGB_1936",SPHEROID["Airy 1830",6377563.396,299.3249646,AUTHORITY["EPSG","7001"]],TOWGS84[375.0,-111.0,431.0,0.0,0.0,0.0,0.0],AUTHORITY["EPSG","6277"]],PRIMEM["Greenwich",0.0,AUTHORITY["EPSG","8901"]],UNIT["DMSH",0.0174532925199433,AUTHORITY["EPSG","9108"]],AXIS["Lat",NORTH],AXIS["Long",EAST],AUTHORITY["EPSG","4277"]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",49.0],PARAMETER["central_meridian",-2.0],PARAMETER["scale_factor",0.999601272],PARAMETER["false_easting",400000.0],PARAMETER["false_northing",-100000.0],UNIT["metre",1.0,AUTHORITY["EPSG","9001"]],AXIS["E",EAST],AXIS["N",NORTH],AUTHORITY["EPSG","27700"]]', obj_.to_wkt)
        end

        def test_parse_epsg_6055
          input_ = 'DATUM["Popular_Visualisation_Datum",SPHEROID["Popular Visualisation Sphere",6378137.0,0.0,AUTHORITY["EPSG","7059"]],TOWGS84[0.0,0.0,0.0,0.0,0.0,0.0,0.0],AUTHORITY["EPSG","6055"]]'
          obj_ = ::RGeo::CoordSys::CS.create_from_wkt(input_)
          assert_kind_of(::RGeo::CoordSys::CS::HorizontalDatum, obj_)
          assert_equal("Popular_Visualisation_Datum", obj_.name)
          assert_equal(::RGeo::CoordSys::CS::HD_GEOCENTRIC, obj_.datum_type)
          assert_equal("EPSG", obj_.authority)
          assert_equal("6055", obj_.authority_code)
          assert_equal("Popular Visualisation Sphere", obj_.ellipsoid.name)
          assert_equal(6_378_137, obj_.ellipsoid.semi_major_axis)
          assert_equal(0, obj_.ellipsoid.inverse_flattening)
          assert_equal(6_378_137, obj_.ellipsoid.semi_minor_axis)
          assert_equal("EPSG", obj_.ellipsoid.authority)
          assert_equal("7059", obj_.ellipsoid.authority_code)
          assert_equal(0, obj_.wgs84_parameters.dx)
          assert_equal(input_, obj_.to_wkt)
        end

        def test_parse_epsg_7405
          input_ = 'COMPD_CS["OSGB36 / British National Grid + ODN",PROJCS["OSGB 1936 / British National Grid",GEOGCS["OSGB 1936",DATUM["OSGB 1936",SPHEROID["Airy 1830",6377563.396,299.3249646,AUTHORITY["EPSG","7001"]],TOWGS84[446.448,-125.157,542.06,0.15,0.247,0.842,-4.2261596151967575],AUTHORITY["EPSG","6277"]],PRIMEM["Greenwich",0.0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.017453292519943295],AXIS["Geodetic latitude",NORTH],AXIS["Geodetic longitude",EAST],AUTHORITY["EPSG","4277"]],PROJECTION["Transverse Mercator",AUTHORITY["EPSG","9807"]],PARAMETER["central_meridian",-2.0],PARAMETER["latitude_of_origin",49.0],PARAMETER["scale_factor",0.9996012717],PARAMETER["false_easting",400000.0],PARAMETER["false_northing",-100000.0],UNIT["m",1.0],AXIS["Easting",EAST],AXIS["Northing",NORTH],AUTHORITY["EPSG","27700"]],VERT_CS["Newlyn",VERT_DATUM["Ordnance Datum Newlyn",2005,AUTHORITY["EPSG","5101"]],UNIT["m",1.0],AXIS["Gravity-related height",UP],AUTHORITY["EPSG","5701"]],AUTHORITY["EPSG","7405"]]'
          obj_ = ::RGeo::CoordSys::CS.create_from_wkt(input_)
          assert_kind_of(::RGeo::CoordSys::CS::CompoundCoordinateSystem, obj_)
          assert_kind_of(::RGeo::CoordSys::CS::ProjectedCoordinateSystem, obj_.head)
          assert_kind_of(::RGeo::CoordSys::CS::VerticalCoordinateSystem, obj_.tail)
          assert_equal(3, obj_.dimension)
          assert_match(_lenient_regex_for(input_), obj_.to_wkt)
        end

        def test_parse_local_datum_with_extension
          input_ = 'LOCAL_DATUM["Random Local Datum",10000,EXTENSION["foo","bar"]]'
          obj_ = ::RGeo::CoordSys::CS.create_from_wkt(input_)
          assert_kind_of(::RGeo::CoordSys::CS::LocalDatum, obj_)
          assert_equal("bar", obj_.extension(:foo))
          assert_nil(obj_.extension(:bar))
          assert_equal(input_, obj_.to_wkt)
        end

        def test_marshal_roundtrip
          input_ = 'COMPD_CS["OSGB36 / British National Grid + ODN",PROJCS["OSGB 1936 / British National Grid",GEOGCS["OSGB 1936",DATUM["OSGB 1936",SPHEROID["Airy 1830",6377563.396,299.3249646,AUTHORITY["EPSG","7001"]],TOWGS84[446.448,-125.157,542.06,0.15,0.247,0.842,-4.2261596151967575],AUTHORITY["EPSG","6277"]],PRIMEM["Greenwich",0.0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.017453292519943295],AXIS["Geodetic latitude",NORTH],AXIS["Geodetic longitude",EAST],AUTHORITY["EPSG","4277"]],PROJECTION["Transverse Mercator",AUTHORITY["EPSG","9807"]],PARAMETER["central_meridian",-2.0],PARAMETER["latitude_of_origin",49.0],PARAMETER["scale_factor",0.9996012717],PARAMETER["false_easting",400000.0],PARAMETER["false_northing",-100000.0],UNIT["m",1.0],AXIS["Easting",EAST],AXIS["Northing",NORTH],AUTHORITY["EPSG","27700"]],VERT_CS["Newlyn",VERT_DATUM["Ordnance Datum Newlyn",2005,AUTHORITY["EPSG","5101"]],UNIT["m",1.0],AXIS["Gravity-related height",UP],AUTHORITY["EPSG","5701"]],AUTHORITY["EPSG","7405"]]'
          obj1_ = ::RGeo::CoordSys::CS.create_from_wkt(input_)
          dump_ = ::Marshal.dump(obj1_)
          obj2_ = ::Marshal.load(dump_)
          assert_equal(obj1_, obj2_)
        end

        def test_yaml_roundtrip
          input_ = 'COMPD_CS["OSGB36 / British National Grid + ODN",PROJCS["OSGB 1936 / British National Grid",GEOGCS["OSGB 1936",DATUM["OSGB 1936",SPHEROID["Airy 1830",6377563.396,299.3249646,AUTHORITY["EPSG","7001"]],TOWGS84[446.448,-125.157,542.06,0.15,0.247,0.842,-4.2261596151967575],AUTHORITY["EPSG","6277"]],PRIMEM["Greenwich",0.0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.017453292519943295],AXIS["Geodetic latitude",NORTH],AXIS["Geodetic longitude",EAST],AUTHORITY["EPSG","4277"]],PROJECTION["Transverse Mercator",AUTHORITY["EPSG","9807"]],PARAMETER["central_meridian",-2.0],PARAMETER["latitude_of_origin",49.0],PARAMETER["scale_factor",0.9996012717],PARAMETER["false_easting",400000.0],PARAMETER["false_northing",-100000.0],UNIT["m",1.0],AXIS["Easting",EAST],AXIS["Northing",NORTH],AUTHORITY["EPSG","27700"]],VERT_CS["Newlyn",VERT_DATUM["Ordnance Datum Newlyn",2005,AUTHORITY["EPSG","5101"]],UNIT["m",1.0],AXIS["Gravity-related height",UP],AUTHORITY["EPSG","5701"]],AUTHORITY["EPSG","7405"]]'
          obj1_ = ::RGeo::CoordSys::CS.create_from_wkt(input_)
          dump_ = Psych.dump(obj1_)
          obj2_ = Psych.load(dump_)
          assert_equal(obj1_, obj2_)
        end
      end
    end
  end
end
