# Flex friendly ActiveRecord patches. More specifically XML serialization improvements.
# These won't override whatever you may normally do with XML, hence there's Flex specific
# name for this stuff +to_fxml+.
module RestfulX
  module Serialization
    class AMFSerializer < ActiveRecord::Serialization::Serializer
      def initialize(record, options = {})
        super(record, options)
        @options[:amf_version] = 3
        @options[:serializer] ||= RestfulX::AMF::AMF3Serializer.new
      end

      def serialize
        @options[:serializer].serialize_record(@record, serializable_attributes, @options) do |serializer|
          add_includes do |association, records, opts|
            add_associations(association, records, opts, serializer)
          end
          yield serializer if block_given?
        end.to_s
      end
      
      def serializable_attributes
        associations = Hash[*@record.class.reflect_on_all_associations(:belongs_to).collect { |assoc| [assoc.primary_key_name, assoc.name] }.flatten]
        serializable_names.map { |name| associations.has_key?(name) ? associations[name] : name.to_sym }
      end

      def add_associations(association, records, opts, serializer)        
        serializer.write_utf8_vr(association.to_s.camelcase(:lower))
        if records.is_a?(Enumerable)
          serializer.stream << RestfulX::AMF::AMF3_OBJECT_MARKER << RestfulX::AMF::AMF3_XML_DOC_MARKER
          serializer.write_utf8_vr('org.restfulx.messaging.io.ModelsCollection')
          serializer.object_cache.cache_index += 2        
          serializer.serialize_records(records, opts)
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
      
      def to_amf(options = {}, &block)
        default_except = [:crypted_password, :salt, :remember_token, :remember_token_expires_at, :created_at, :updated_at]
        options[:except] = (options[:except] ? options[:except] + default_except : default_except)
        serializer = RestfulX::Serialization::AMFSerializer.new(self, options)
        block_given? ? serializer.to_s(&block) : serializer.to_s
      end
    
      def to_fxml(options = {}, &block)
        options.merge!(:dasherize => false)
        default_except = [:crypted_password, :salt, :remember_token, :remember_token_expires_at, :created_at, :updated_at]
        options[:except] = (options[:except] ? options[:except] + default_except : default_except)
        to_xml(options, &block)
      end      
    end
  end
end

module ActiveRecord
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
  # when errors are serialized to XML
  class Errors
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
    
    def to_amf(options = {})
      #TODO
    end
  end
end