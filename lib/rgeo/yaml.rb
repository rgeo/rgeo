# -----------------------------------------------------------------------------
#
# RGeo yaml support
#
# -----------------------------------------------------------------------------

begin
  require "psych"
rescue ::LoadError
end

module RGeo
  # :stopdoc:
  PSYCH_AVAILABLE = defined?(::Psych)
  # :startdoc:

  # Returns true if YAML serialization and deserialization is supported.
  # YAML support requires the Psych library/gem.

  def self.yaml_supported?
    PSYCH_AVAILABLE
  end
end
