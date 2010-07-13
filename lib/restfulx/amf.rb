$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
$:.unshift "#{File.expand_path(File.dirname(__FILE__))}/amf/"

require 'amf/class_mapping'

module RestfulX::AMF
  attr :serializer, true
  
  ClassMapper = RestfulX::AMF::ClassMapping.new
  
  def self.serializer
    return @serializer
  end
  
  def self.serializer=(value)
    @serializer = value
  end
  
  begin
    if @serializer == :native
      require 'amf/ext'
    else
      require 'amf/pure'
    end
  rescue LoadError
    require 'amf/pure'
  end
      
  # The base exception for AMF errors.
  class AMFError < StandardError; end
end