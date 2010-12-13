$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'amf/class_mapping'
require 'amf/pure'

# implements ruby-side AMF support for RestfulX
module RestfulX::AMF
  ClassMapper = RestfulX::AMF::ClassMapping.new
end