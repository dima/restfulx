$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'amf/class_mapping'

module RestfulX::AMF
  
  ClassMapper = RestfulX::AMF::ClassMapping.new
  
  begin
    require RestfulX.amf_serializer == :native ? 'amf/ext' : 'amf/pure'
  rescue LoadError
    require 'amf/pure'
  end
end