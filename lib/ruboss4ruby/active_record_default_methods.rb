module ActiveRecord
  #
  # We also add support for serializing model methods along the lines of:
  #
  #   class Project < ActiveRecord::Base
  #     default_methods :foobar
  #
  #     def foobar
  #       'foobar'
  #     end
  #   end
  #
  # When you do +to_fxml+ on this model method foobar will be automatically
  # serialized as a simple attribute
  class Base
    class << self
            
      # default methods hook
      def default_methods(*args)
        methods = *args.dup
        module_eval <<-END 
            def self.default_methods_array
              return [#{methods.inspect}].flatten
            end
          END
      end
      
      # default methods hook
      def defaults_hash(already_included = [], ignore_default_methods = nil)
        defaults_hash = {:include => {}}
        unless ignore_default_methods
          defaults_hash[:methods] = self.default_methods_array if self.respond_to?(:default_methods_array)
        end
        defaults_hash
      end 
    end
  end    
  
  # Flex-friendly serialization patches
  module Serialization
    
    alias_method :xml_defaults_old_to_xml, :to_xml unless method_defined?(:xml_defaults_old_to_xml)
    
    alias_method :json_defaults_old_to_json, :to_json unless method_defined?(:json_defaults_old_to_json)
    
    # adds support for default_methods to standard +to_xml+
    def to_xml(options = {}, &block)
      unless options[:ignore_defaults]
        unless options[:ignore_default_methods]
          options[:methods] = [options[:methods] || []].flatten + (self.class.defaults_hash[:methods] || [])
        end
      end
      xml_defaults_old_to_xml(options, &block)
    end
    
    # adds support for default_methods to standard +to_json+
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