module RestfulX
  module Serialization
    class FXMLSerializer < ::ActiveRecord::Serialization::Serializer
      def builder
        @builder ||= begin
          options[:indent] ||= 2
          builder = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])

          unless options[:skip_instruct]
            builder.instruct!
            options[:skip_instruct] = true
          end

          builder
        end
      end

      def root
        root = (options[:root] || @record.class.to_s.underscore).to_s
        reformat_name(root)
      end

      def dasherize?
        !options.has_key?(:dasherize) || options[:dasherize]
      end

      def camelize?
        options.has_key?(:camelize) && options[:camelize]
      end

      def reformat_name(name)
        name = name.camelize if camelize?
        dasherize? ? name.dasherize : name
      end

      def serializable_attributes
        serializable_attribute_names.collect { |name| Attribute.new(name, @record) }
      end

      def serializable_method_attributes
        Array(options[:methods]).inject([]) do |method_attributes, name|
          method_attributes << MethodAttribute.new(name.to_s, @record) if @record.respond_to?(name.to_s)
          method_attributes
        end
      end

      def add_attributes
        (serializable_attributes + serializable_method_attributes).each do |attribute|
          add_tag(attribute)
        end
      end

      def add_procs
        if procs = options.delete(:procs)
          [ *procs ].each do |proc|
            proc.call(options)
          end
        end
      end

      def add_tag(attribute)
        builder.tag!(
          reformat_name(attribute.name),
          attribute.value.to_s,
          attribute.decorations(!options[:skip_types])
        )
      end

      def add_associations(association, records, opts)
        if records.is_a?(Enumerable)
          tag = reformat_name(association.to_s)
          type = options[:skip_types] ? {} : {:type => "array"}

          if records.empty?
            builder.tag!(tag, type)
          else
            builder.tag!(tag, type) do
              association_name = association.to_s.singularize
              records.each do |record|
                if options[:skip_types]
                  record_type = {}
                else
                  record_class = (record.class.to_s.underscore == association_name) ? nil : record.class.name
                  record_type = {:type => record_class}
                end

                record.to_fxml opts.merge(:root => association_name).merge(record_type)
              end
            end
          end
        else
          if record = @record.send(association)
            record.to_fxml(opts.merge(:root => association))
          end
        end
      end

      def serialize
        args = [root]
        if options[:namespace]
          args << {:xmlns=>options[:namespace]}
        end

        if options[:type]
          args << {:type=>options[:type]}
        end

        builder.tag!(*args) do
          add_attributes
          procs = options.delete(:procs)
          add_includes { |association, records, opts| add_associations(association, records, opts) }
          options[:procs] = procs
          add_procs
          yield builder if block_given?
        end
      end
      
      class Attribute #:nodoc:
        attr_reader :name, :value, :type

        def initialize(name, record)
          @name, @record = name, record

          @type  = compute_type
          @value = compute_value
        end

        # There is a significant speed improvement if the value
        # does not need to be escaped, as <tt>tag!</tt> escapes all values
        # to ensure that valid XML is generated. For known binary
        # values, it is at least an order of magnitude faster to
        # Base64 encode binary values and directly put them in the
        # output XML than to pass the original value or the Base64
        # encoded value to the <tt>tag!</tt> method. It definitely makes
        # no sense to Base64 encode the value and then give it to
        # <tt>tag!</tt>, since that just adds additional overhead.
        def needs_encoding?
          ![ :binary, :date, :datetime, :boolean, :float, :integer ].include?(type)
        end

        def decorations(include_types = true)
          decorations = {}

          if type == :binary
            decorations[:encoding] = 'base64'
          end

          if include_types && type != :string
            decorations[:type] = type
          end

          if value.nil?
            decorations[:nil] = true
          end

          decorations
        end

        protected
          def compute_type
            type = @record.class.serialized_attributes.has_key?(name) ? :yaml : @record.class.columns_hash[name].type

            case type
              when :text
                :string
              when :time
                :datetime
              else
                type
            end
          end

          def compute_value
            value = @record.send(name)

            if formatter = Hash::XML_FORMATTING[type.to_s]
              value ? formatter.call(value) : nil
            else
              value
            end
          end
      end

      class MethodAttribute < Attribute #:nodoc:
        protected
          def compute_type
            Hash::XML_TYPE_NAMES[@record.send(name).class.name] || :string
          end
      end
    end
    
    class AMFSerializer < ::ActiveRecord::Serialization::Serializer
      def initialize(record, options = {})
        super(record, options)
        @options[:methods] ||= []
        @options[:amf_version] = 3
        @options[:serializer] ||= RestfulX::AMF::RxAMFSerializer.new
        
        # options are duplicated by default so we need a copy for caching attributes
        @original_options = options
        @original_options[:cached_attributes] ||= {}
        @options[:cached_instances] = @original_options[:cached_instances] ||= {}
      end

      def serialize
        @options[:serializer].serialize_record(@record, serializable_attributes, @options) do |serializer|
          ([].concat(@options[:methods])).each do |method|
            if @record.respond_to?(method)
              serializer.write_vr(method.to_s.camelcase(:lower))
              serializer.serialize_property(@record.send(method))
            end
          end
          add_includes do |association, records, opts|
            add_associations(association, records, opts, serializer)
          end
        end.to_s
      end
      
      def serializable_attributes
        includes = @options[:include] ||= {}
        
        # if we are serializing an array we only need to compute serializable_attributes for the
        # objects of the same type at the same level once
        if @original_options[:cached_attributes].has_key?(@record.class.name)
          @original_options[:cached_attributes][@record.class.name]
        else
          associations = Hash[*@record.class.reflect_on_all_associations(:belongs_to).collect do |assoc|
            if assoc.options.has_key?(:polymorphic) && assoc.options[:polymorphic]
              @options[:except] = ([] << @options[:except] << "#{assoc.name}_type".to_sym).flatten
              class_name = @record[assoc.options[:foreign_type]].constantize
            else
              class_name = assoc.klass
            end
            [assoc.primary_key_name, {:name => assoc.name, :klass => class_name}]
          end.flatten]
                                
          attributes = serializable_names.select do |name| 
            !includes.include?(associations[name][:name]) rescue true
          end.map do |name| 
            associations.has_key?(name) ? {:name => name, :ref_name => associations[name][:name].to_s.camelize(:lower), 
              :ref_class => associations[name][:klass] } : name.to_sym
          end
          @original_options[:cached_attributes][@record.class.name] = attributes
          attributes
        end
      end
      
      def add_associations(association, records, opts, serializer)        
        serializer.write_vr(association.to_s.camelcase(:lower))
        if records.is_a?(Enumerable)
          serializer.serialize_models_array(records, opts)
        else
          if record = @record.send(association)
            record.to_amf(opts)
          end
        end
      end
    end
  end
  
  module ActiveRecord
    def self.included(base)
      base.send :include, InstanceMethods
    end
    
    module InstanceMethods
      def unique_id
        "#{self.class.to_s}_#{self.attributes()['id']}"
      end
      
      def to_amf(options = {})
        default_except = [:crypted_password, :salt, :remember_token, :remember_token_expires_at, :created_at, :updated_at]
        options[:except] = (options[:except] ? options[:except] + default_except : default_except)
        
        RestfulX::Serialization::AMFSerializer.new(self, options).to_s
      end
    
      def to_fxml(options = {})
        options.merge!(:dasherize => false)
        default_except = [:crypted_password, :salt, :remember_token, :remember_token_expires_at, :created_at, :updated_at]
        options[:except] = (options[:except] ? options[:except] + default_except : default_except)
        
        RestfulX::Serialization::FXMLSerializer.new(self, options).to_s
      end
    end
  end
end

module ActiveRecord
  # ActiveRecord named scopes are computed *before* restfulx gem gets loaded
  # this patch addresses that and makes sure +to_fxml/to_amf+ calls are properly
  # delegated
  module NamedScope
    # make sure we properly delegate +to_fxml+ calls to the proxy
    class Scope
      delegate :to_fxml, :to => :proxy_found
      delegate :to_amf,  :to => :proxy_found
    end
  end
  
  # Change the xml serializer so that '?'s are stripped from attribute names.
  # This makes it possible to serialize methods that end in a question mark, like 'valid?' or 'is_true?'
  class XmlSerializer
    # Strips '?' from serialized method names
    def add_tag(attribute)
      builder.tag!(
        dasherize? ? attribute.display_name.dasherize : attribute.display_name,
        attribute.value.to_s,
        attribute.decorations(!options[:skip_types])
      )
    end
    # Strips '?' from serialized method names
    class Attribute
      # Strips '?' from serialized method names
      def display_name
        @name.gsub('?','')
      end
    end
  end

  # Add more extensive reporting on errors including field name along with a message
  # when errors are serialized to XML and JSON
  class Errors
    alias_method :to_json_original, :to_json
    
    # Flex friendly errors
    def to_fxml(options = {})
      options[:root] ||= "errors"
      options[:indent] ||= 2
      options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
      options[:builder].instruct! unless options.delete(:skip_instruct)
      options[:builder].errors do |e|
        # The @errors instance variable is a Hash inside the Errors class
        @errors.each do |attr, msg|
          next if msg.nil?
          if attr == "base"
            options[:builder].error("message", msg.to_s)
          else
            options[:builder].error("field" => attr.camelcase(:lower), "message" => msg.to_s)
          end
        end
      end
    end
    
    def to_json(options = {})
      "{#{'errors'.inspect}:#{to_json_original(options)}}"
    end
    
    def to_amf(options = {})
      options[:amf_version] = 3
      options[:serializer] ||= RestfulX::AMF::RxAMFSerializer.new
      options[:serializer].serialize_errors(Hash[*@errors.to_a.flatten]).to_s
    end
  end
end