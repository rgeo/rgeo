VALUE
extract_points_from_coordinate_sequence(GEOSContextHandle_t context,
                                        const GEOSCoordSequence* coord_sequence,
                                        int zCoordinate);
VALUE
extract_points_from_polygon(GEOSContextHandle_t context,
                            const GEOSGeometry* polygon,
                            int zCoordinate);
