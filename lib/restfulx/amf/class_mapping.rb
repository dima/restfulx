module RestfulX::AMF
  class ClassMapping
    class MappingSet
      attr_accessor :default_as_prefix
      
      def initialize #:nodoc:
        @as_mappings = {}
        @ruby_mappings = {}
        @meta_data = {}
        @default_as_prefix = ""

        # Map defaults
        # map :as => 'flex.messaging.messages.AbstractMessage', :ruby => 'AMF::Messages::AbstractMessage'
        # map :as => 'flex.messaging.messages.RemotingMessage', :ruby => 'AMF::Messages::RemotingMessage'
        # map :as => 'flex.messaging.messages.AsyncMessage', :ruby => 'AMF::Messages::AsyncMessage'
        # map :as => 'flex.messaging.messages.CommandMessage', :ruby => 'AMF::Messages::CommandMessage'
        # map :as => 'flex.messaging.messages.AcknowledgeMessage', :ruby => 'AMF::Messages::AcknowledgeMessage'
        # map :as => 'flex.messaging.messages.ErrorMessage', :ruby => 'AMF::Messages::ErrorMessage'
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
        
        if params.key?(:ruby) and (params.key?(:static) or params.key?(:dynamic) or params.key?(:type))
          
          type    = params[:type]
          static  = params[:static]
          dynamic = params[:dynamic]
          
          unless type
            if static and (dynamic.nil? or dynamic.empty?)
              type = :static
            else
              type = :dynamic
            end
          end
          
          @meta_data[params[:ruby]] = { :type => type, :static => static, :dynamic => dynamic }
        end
      end

      # Returns the AS class name for the given ruby class name, returing nil if
      # not found
      def get_as_class_name(class_name) #:nodoc:
        unless as_class_name = @ruby_mappings[class_name.to_s]
          as_class_name = "#{@default_as_prefix}.#{class_name}"
        end
        as_class_name
      end

      # Returns the ruby class name for the given AS class name, returing nil if
      # not found
      def get_ruby_class_name(class_name) #:nodoc:
        unless ruby_class_name = @as_mappings[class_name.to_s]
          ruby_class_name = class_name.sub("#{default_as_prefix}.", "")
        end
        ruby_class_name
      end
      
      def get_meta_data_for_ruby_class(class_name)
        @meta_data[class_name.to_s] || { :type => :dynamic }
      end
      
      def get_meta_data_for_as_class(class_name)
        get_meta_data_for_ruby_class(get_ruby_class_name(class_name))
      end
    end

    # Define class mappings in the block. Block is passed a MappingSet object as
    # the first parameter.
    #
    # Example:
    #
    #   AMF::ClassMapper.define do |m|
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
      
      if obj.is_a?(ActiveRecord::Base)
        mappings.get_as_class_name(ruby_class_name)
      else
        nil
      end
    end
    
    def get_ruby_class_name(as_class_name)
      mappings.get_ruby_class_name(as_class_name.to_s)
    end
    
    def get_meta_data_for_ruby_class(obj)
      # Get class name
      if obj.is_a?(String)
        ruby_class_name = obj
      else
        ruby_class_name = obj.class.name
      end
      
      mappings.get_meta_data_for_ruby_class(ruby_class_name)
    end
    
    def get_meta_data_for_as_class(as_class_name)
      mappings.get_meta_data_for_as_class(as_class_name.to_s)
    end

    # Instantiates a ruby object using the mapping configuration based on the
    # source AS class name. If there is no mapping defined, it returns a hash.
    def get_ruby_obj(as_class_name)
      ruby_class_name = mappings.get_ruby_class_name(as_class_name)
      if ruby_class_name.nil? || ruby_class_name.empty?
        # Populate a simple hash, since no mapping
        return Hash.new
      else
        ruby_class = deep_const_get(ruby_class_name)
        return ruby_class.new
      end
    end
    
    # Return the constant located at _path_. The format of _path_ has to be
    # either ::A::B::C or A::B::C. In any case A has to be located at the top
    # level (absolute namespace path?). If there doesn't exist a constant at
    # the given path, an ArgumentError is raised.
    def deep_const_get(path) # :nodoc:
      path.to_s.split('::').inject(Kernel) { |scope, const_name| scope.const_get(const_name) }
    end

    # Populates the ruby object using the given properties
    def populate_ruby_obj(obj, props, dynamic_props=nil)
      props.merge! dynamic_props if dynamic_props
      hash_like = obj.respond_to?("[]=")
      props.each do |key, value|
        if obj.respond_to?("#{key}=")
          obj.send("#{key}=", value)
        elsif hash_like
          obj[key.to_sym] = value
        end
      end
      obj
    end

    private
    def mappings
      @mappings ||= MappingSet.new
    end
  end
end