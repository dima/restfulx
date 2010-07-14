module RestfulX::AMF
  class ClassMapping
    class MappingSet
      attr_accessor :default_as_prefix
      
      def initialize #:nodoc:
        @as_mappings = {}
        @ruby_mappings = {}
        @default_as_prefix = ""
      end

      # Map a given AS class to a ruby class.
      #
      # Use fully qualified names for both.
      #
      # Example:
      #
      #   m.map :as 'com.example.Date', :ruby => 'Example::Date'
      def map(params)
        [:as, :ruby].each {|k| params[k] = params[k].to_s if params[k] } # Convert params to strings
        
        if params.key?(:as) and params.key?(:ruby)
          @as_mappings[params[:as]] = params[:ruby]
          @ruby_mappings[params[:ruby]] = params[:as]
        end
        
        if params.key?(:as)
          params[:ruby] = get_ruby_class_name(params[:as])
        end
      end

      # Returns the AS class name for the given ruby class name, returing nil if
      # not found
      def get_as_class_name(class_name) #:nodoc:
        unless as_class_name = @ruby_mappings[class_name.to_s]
          as_class_name = "#{@default_as_prefix}.#{class_name}"
          @as_mappings[as_class_name] = class_name.to_s
          @ruby_mappings[class_name.to_s] = as_class_name
        end
        as_class_name
      end

      # Returns the ruby class name for the given AS class name, returing nil if
      # not found
      def get_ruby_class_name(class_name) #:nodoc:
        unless ruby_class_name = @as_mappings[class_name.to_s]
          ruby_class_name = class_name.sub("#{default_as_prefix}.", "")
          @ruby_mappings[ruby_class_name] = class_name.to_s
          @as_mappings[class_name.to_s] = ruby_class_name
        end
        ruby_class_name
      end
    end

    # Define class mappings in the block. Block is passed a MappingSet object as
    # the first parameter.
    #
    # Example:
    #
    #   RestfulX::AMF::ClassMapper.define do |m|
    #     m.map :as => 'AsClass', :ruby => 'RubyClass'
    #   end
    def define #:yields: mapping_set
      yield mappings
    end
    
    def default_as_prefix
      mappings.default_as_prefix
    end
    
    def default_as_prefix=(value)
      mappings.default_as_prefix = value
    end

    # Returns the AS class name for the given ruby object. Will also take a string
    # containing the ruby class name
    def get_as_class_name(obj)
      # Get class name
      if obj.is_a?(String)
        ruby_class_name = obj
      else
        ruby_class_name = obj.class.name
      end
      
      if obj.respond_to?(:unique_id)
        mappings.get_as_class_name(ruby_class_name)
      else
        nil
      end
    end
    
    def get_ruby_class_name(as_class_name)
      mappings.get_ruby_class_name(as_class_name.to_s)
    end

    private
    def mappings
      @mappings ||= MappingSet.new
    end
  end
end