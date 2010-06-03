$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
$:.unshift "#{File.expand_path(File.dirname(__FILE__))}/amf/"

require 'amf/class_mapping'
require 'amf/constants'

module RestfulX::AMF
  class SerializerCache < Hash
    attr_accessor :cache_index
  
    def initialize
      @cache_index = 0
    end

    def cache(obj)
      self[obj] = @cache_index
      @cache_index += 1
    end
  end
  
  # begin
  #   require 'amf/ext'
  #   puts "using native C AMF serializer"
  # rescue LoadError
  #   require 'amf/pure'
  #   puts "using pure AMF serializer"
  # end
  
  require 'amf/pure'
  puts "using pure AMF serializer"
  
  require 'amf/common'
  
  ClassMapper = RestfulX::AMF::ClassMapping.new
  
  # The base exception for AMF errors.
  class AMFError < StandardError; end
end