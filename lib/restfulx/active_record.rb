# Flex friendly ActiveRecord patches. More specifically XML serialization improvements.
# These won't override whatever you may normally do with XML, hence there's Flex specific
# name for this stuff +to_fxml+.
module RestfulX
  module Serialization
    class AMFSerializer < ActiveRecord::Serialization::Serializer
      def initialize(record, options = {})
        super(record, options)
        @options[:amf_version] = 3
      end

      def serialize
        serializer = RestfulX::AMF::AMF3Serializer.new({:serializable_names => serializable_names, :options => @options})

        serializer.serialize(@record) do |s|
          add_includes do |association, records, opts|
            add_associations(association, records, opts, s)
          end
          yield serializer if block_given?
        end
      end

      def add_associations(association, records, opts, serializer)
        if records.is_a?(Enumerable)
          serializer.write_nested_collection(association.to_s, records)
        else
          if record = @record.send(association)
            serializer.write_nested_association(association.to_s, record)
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
      def to_amf(options = {}, &block)
        serializer = RestfulX::Serialization::AMFSerializer.new(self, options)
        block_given? ? serializer.to_s(&block) : serializer.to_s
      end
    
      def to_fxml(options = {}, &block)
        options.merge!(:dasherize => false)
        default_except = [:crypted_password, :salt, :remember_token, :remember_token_expires_at]
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