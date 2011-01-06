require 'active_support/xml_mini'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/core_ext/string/inflections'
require 'active_support/json'

class Array
  alias_method :as_json_original, :as_json
  
  # Serialize array as RestfulX friendly JSON (with metadata)
  def as_json(options = {})
    attributes = options.delete(:attributes)
    return (attributes.nil?) ? as_json_original(options) : "[{#{'metadata'.inspect}: #{attributes.as_json}},#{as_json_original(options)[1..-1]}]"
  end
  
  def to_fxml(options = {})
    require 'active_support/builder' unless defined?(Builder)

    options = options.dup
    options.merge!(:dasherize => false)
    options[:indent] ||= 2
    options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    options[:root] ||= if first.class.to_s != "Hash" && all? { |e| e.is_a?(first.class) }
      underscored = ActiveSupport::Inflector.underscore(first.class.name)
      ActiveSupport::Inflector.pluralize(underscored).tr('/', '_')
    else
      "objects"
    end

    builder = options[:builder]
    builder.instruct! unless options.delete(:skip_instruct)

    root = ActiveSupport::XmlMini.rename_key(options[:root].to_s, options)
    children = options.delete(:children) || root.singularize

    options[:attributes] ||= {}
    options[:attributes].merge!(:type => "array") unless options[:skip_types]
    
    return builder.tag!(root, options[:attributes]) if empty?

    builder.__send__(:method_missing, root, options[:attributes]) do
      each { |value| ActiveSupport::XmlMini.to_tag(children, value, options) }
      yield builder if block_given?
    end
  end
  
  # Serialize as AMF
  def to_amf(options = {})    
    options[:attributes] ||= {}
    options[:serializer] ||= RestfulX::AMF::RxAMFSerializer.new
    options[:serializer].serialize_typed_array(self, options).to_s
  end
end