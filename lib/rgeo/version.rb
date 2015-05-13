# -----------------------------------------------------------------------------
#
# RGeo version
#
# -----------------------------------------------------------------------------

begin
  require 'versionomy'
rescue ::LoadError
end


module RGeo

  # Current version of RGeo as a frozen string
  VERSION_STRING = ::File.read(::File.dirname(__FILE__)+'/../../Version').strip.freeze

  # Current version of RGeo as a Versionomy object, if the Versionomy gem
  # is available.
  VERSION = defined?(::Versionomy) ? ::Versionomy.parse(VERSION_STRING) : VERSION_STRING

end
