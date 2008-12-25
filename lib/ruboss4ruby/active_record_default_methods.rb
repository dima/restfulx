module ActiveRecord
  
  class Base
    class << self
            
      def default_methods(*args)
        methods = *args.dup
        module_eval <<-END 
            def self.default_methods_array
              return [#{methods.inspect}].flatten
            end
          END
      end
            
      def defaults_hash(already_included = [], ignore_default_methods = nil)
        defaults_hash = {:include => {}}
        unless ignore_default_methods
          defaults_hash[:methods] = self.default_methods_array if self.respond_to?(:default_methods_array)
        end
        defaults_hash
      end 

    end
  
  end    
  
  module Serialization
    
    alias_method :xml_defaults_old_to_xml, :to_xml unless method_defined?(:xml_defaults_old_to_xml)
    
    alias_method :json_defaults_old_to_json, :to_json unless method_defined?(:json_defaults_old_to_json)
    
    def to_xml(options = {}, &block)
      unless options[:ignore_defaults]
        unless options[:ignore_default_methods]
          options[:methods] = [options[:methods] || []].flatten + (self.class.defaults_hash[:methods] || [])
        end
      end
      xml_defaults_old_to_xml(options, &block)
    end
    
    def to_json(options = {}, &block)
      unless options[:ignore_defaults]
        unless options[:ignore_default_methods]
          options[:methods] = [options[:methods] || []].flatten + (self.class.defaults_hash[:methods] || [])
        end
      end
      json_defaults_old_to_json(options, &block)      
    end
    
  end
    
 
end