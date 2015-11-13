#include <ruby.h>
#include <geos_c.h>


VALUE extract_points_from_coordinate_sequence(GEOSContextHandle_t context, const GEOSCoordSequence* coord_sequence, int zCoordinate)
{
  VALUE result = Qnil;
  VALUE point;
  unsigned int count;
  unsigned int i;
  double val;

  if(GEOSCoordSeq_getSize_r(context, coord_sequence, &count)) {
    result = rb_ary_new2(count);
    for(i = 0; i < count; ++i) {
      if(zCoordinate) {
        point = rb_ary_new2(3);
      } else {
        point = rb_ary_new2(2);
      }
      GEOSCoordSeq_getX_r(context, coord_sequence, i, &val);
      rb_ary_push(point, rb_float_new(val));
      GEOSCoordSeq_getY_r(context, coord_sequence, i, &val);
      rb_ary_push(point, rb_float_new(val));
      if(zCoordinate) {
        GEOSCoordSeq_getZ_r(context, coord_sequence, i, &val);
        rb_ary_push(point, rb_float_new(val));
      }
      rb_ary_push(result, point);
    }
  }

  return result;
}

VALUE extract_points_from_polygon(GEOSContextHandle_t context, const GEOSGeometry* polygon, int zCoordinate)
{
  VALUE result = Qnil;

  const GEOSGeometry* ring;
  const GEOSCoordSequence* coord_sequence;
  unsigned int interior_ring_count;
  unsigned int i;

  if (polygon) {
    ring = GEOSGetExteriorRing_r(context, polygon);
    coord_sequence = GEOSGeom_getCoordSeq_r(context, ring);

    if(coord_sequence) {
      interior_ring_count = GEOSGetNumInteriorRings_r(context, polygon);
      result = rb_ary_new2(interior_ring_count + 1); // exterior + inner rings

      rb_ary_push(result, extract_points_from_coordinate_sequence(context, coord_sequence, zCoordinate));

      for(i = 0; i < interior_ring_count; ++i) {
        ring = GEOSGetInteriorRingN_r(context, polygon, i);
        coord_sequence = GEOSGeom_getCoordSeq_r(context, ring);
        if(coord_sequence) {
          rb_ary_push(result, extract_points_from_coordinate_sequence(context, coord_sequence, zCoordinate));
        }
      }
    }
  }
  return result;
}
