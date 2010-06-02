require 'amf/pure/serializer'

module RestfulX::AMF
  # This module holds all the modules/classes that implement AMF's
  # functionality in pure ruby.
  module Pure
    $DEBUG and warn "Using pure library for AMF."
  end

  include RestfulX::AMF::Pure
end