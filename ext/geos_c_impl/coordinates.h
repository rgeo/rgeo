VALUE
extract_points_from_coordinate_sequence(const GEOSCoordSequence* coord_sequence,
                                        int has_z, int has_m);
VALUE
extract_points_from_polygon(const GEOSGeometry* polygon, int has_z, int has_m);
