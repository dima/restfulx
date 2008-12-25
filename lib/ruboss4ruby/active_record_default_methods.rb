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
      
      # options[:include] can be a Hash, Array, Symbol or nil.
      # We always want it as a Hash.  This translates includes to a Hash like this:
      # If it's a nil, return an empty Hash ({})
      # If it's a Hash, then it is just returned
      # If it's an array, then it returns a Hash with each array element as a key, and values of empty Hashes.
      # If it's a symbol, then it returns a Hash with a single key/value pair, with the symbol as the key and an empty Hash as the value.
      def includes_as_hash(includes = nil)      
        res = case
          when includes.is_a?(Hash)
            includes      
          when includes.nil?
           {}  
          else #Deal with arrays and symbols
            res = [includes].flatten.inject({}) {|include_hash, included| include_hash[included] = {} ; include_hash}
        end
        res
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