#include <geos_c.h>
#include <ruby.h>

VALUE
extract_points_from_coordinate_sequence(const GEOSCoordSequence* coord_sequence,
                                        int has_z, int has_m)
{
  VALUE result = Qnil;
  VALUE point;
  unsigned int count;
  unsigned int i;
  double val;
  int dims = 2 + (has_z ? 1 : 0) + (has_m ? 1 : 0);

  if (GEOSCoordSeq_getSize(coord_sequence, &count)) {
    result = rb_ary_new2(count);
    for (i = 0; i < count; ++i) {
      point = rb_ary_new2(dims);
      GEOSCoordSeq_getX(coord_sequence, i, &val);
      rb_ary_push(point, rb_float_new(val));
      GEOSCoordSeq_getY(coord_sequence, i, &val);
      rb_ary_push(point, rb_float_new(val));
      if (has_z) {
        GEOSCoordSeq_getZ(coord_sequence, i, &val);
        rb_ary_push(point, rb_float_new(val));
      }
      if (has_m) {
        GEOSCoordSeq_getM(coord_sequence, i, &val);
        rb_ary_push(point, rb_float_new(val));
      }
      rb_ary_push(result, point);
    }
  }

  return result;
}

VALUE
extract_points_from_polygon(const GEOSGeometry* polygon, int has_z, int has_m)
{
  VALUE result = Qnil;

  const GEOSGeometry* ring;
  const GEOSCoordSequence* coord_sequence;
  unsigned int interior_ring_count;
  unsigned int i;

  if (polygon) {
    ring = GEOSGetExteriorRing(polygon);
    coord_sequence = GEOSGeom_getCoordSeq(ring);

    if (coord_sequence) {
      interior_ring_count = GEOSGetNumInteriorRings(polygon);
      result = rb_ary_new2(interior_ring_count + 1); // exterior + inner rings

      rb_ary_push(
        result,
        extract_points_from_coordinate_sequence(coord_sequence, has_z, has_m));

      for (i = 0; i < interior_ring_count; ++i) {
        ring = GEOSGetInteriorRingN(polygon, i);
        coord_sequence = GEOSGeom_getCoordSeq(ring);
        if (coord_sequence) {
          rb_ary_push(result,
                      extract_points_from_coordinate_sequence(coord_sequence,
                                                              has_z, has_m));
        }
      }
    }
  }
  return result;
}
