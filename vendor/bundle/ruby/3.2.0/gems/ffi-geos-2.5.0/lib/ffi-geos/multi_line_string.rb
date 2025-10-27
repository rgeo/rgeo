# frozen_string_literal: true

module Geos
  class MultiLineString < GeometryCollection
    if FFIGeos.respond_to?(:GEOSisClosed_r) && Geos::GEOS_NICE_VERSION >= '030500'
      # Available in GEOS 3.5.0+.
      def closed?
        bool_result(FFIGeos.GEOSisClosed_r(Geos.current_handle_pointer, ptr))
      end
    end
  end
end
