require 'restfulx/amf/ext/serializer'

module RestfulX::AMF #:nodoc:
  # This module holds all the modules/classes that implement AMF's
  # functionality in native C code
  module Ext
    $DEBUG and warn "Using native extension for AMF."
  end

  include RestfulX::AMF::Ext
end