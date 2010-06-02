require 'restfulx/amf/ext/serializer'

module RestfulX::AMF
  # This module holds all the modules/classes that implement AMF's
  # functionality in pure ruby.
  module Ext
    $DEBUG and warn "Using native extension for AMF."
  end

  include RestfulX::AMF::Ext
end