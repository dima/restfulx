require 'active_support/core_ext/array/wrap'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/array/conversions'
require 'active_support/core_ext/hash/conversions'
require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/blank'
require 'active_support/ordered_hash'

module RestfulX
  
  module ActiveRecord #:nodoc:
    module Serialization
      include RestfulX::ActiveModel::Serializers::Fxml
  
      def to_fxml(options = {}, &block)
        options.merge!(:dasherize => false)
        default_except = [:encrypted_password, :password_salt, :remember_token, :remember_token_expires_at, :created_at, :updated_at]
        options[:except] = (options[:except] ? options[:except] + default_except : default_except)
        FxmlSerializer.new(self, options).serialize(&block)
      end
    end
  
    class FxmlSerializer < RestfulX::ActiveModel::Serializers::Fxml::Serializer #:nodoc:
      def initialize(*args)
        super
        options[:except] |= Array.wrap(@serializable.class.inheritance_column)
      end
  
      def add_extra_behavior
        add_includes
      end
  
      def add_includes
        procs = options.delete(:procs)
        @serializable.send(:serializable_add_includes, options) do |association, records, opts|
          add_associations(association, records, opts)
        end
        options[:procs] = procs
      end
  
      # TODO This can likely be cleaned up to simple use ActiveSupport::XmlMini.to_tag as well.
      def add_associations(association, records, opts)
        association_name = association.to_s.singularize
        merged_options = options.merge(opts).merge!(:root => association_name, :skip_instruct => true)
  
        if records.is_a?(Enumerable)
          tag = ActiveSupport::XmlMini.rename_key(association.to_s, options)
          type = options[:skip_types] ? { } : {:type => "array"}
  
          if records.empty?
            @builder.tag!(tag, type)
          else
            @builder.tag!(tag, type) do
              records.each do |record|
                if options[:skip_types]
                  record_type = {}
                else
                  record_class = (record.class.to_s.underscore == association_name) ? nil : record.class.name
                  record_type = {:type => record_class}
                end
  
                record.to_xml merged_options.merge(record_type)
              end
            end
          end
        elsif record = @serializable.send(association)
          record.to_xml(merged_options)
        end
      end
  
      class Attribute < RestfulX::ActiveModel::Serializers::Fxml::Serializer::Attribute #:nodoc:
        def compute_type
          type = @serializable.class.serialized_attributes.has_key?(name) ?
            super : @serializable.class.columns_hash[name].type
  
          case type
          when :text
            :string
          when :time
            :datetime
          else
            type
          end
        end
        protected :compute_type
      end
    end
  end
end
