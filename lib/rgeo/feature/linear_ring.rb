# -----------------------------------------------------------------------------
#
# LinearRing feature interface
#
# -----------------------------------------------------------------------------

module RGeo
  module Feature
    # == SFS 1.1 Description
    #
    # A LinearRing is a LineString that is both closed and simple.
    #
    # == Notes
    #
    # LinearRing is defined as a module and is provided primarily
    # for the sake of documentation. Implementations need not necessarily
    # include this module itself. Therefore, you should not depend on the
    # kind_of? method to check type. Instead, use the provided check_type
    # class method (or === operator) defined in the Type module.

    module LinearRing
      include LineString
      extend Type
    end
  end
end
