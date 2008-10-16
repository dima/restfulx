#ActiveRecord+ActiveSupport specific patches

# Flex friendly date, datetime formats
ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(:flex_date => "%Y/%m/%d")
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(:flex_datetime => "%Y/%m/%d %H:%M:%S")

Hash::XML_FORMATTING['date'] = Proc.new { |date| date.to_s(:flex_date) }
Hash::XML_FORMATTING['datetime'] = Proc.new { |datetime| datetime.to_s(:flex_datetime) }

class ClassyEmptyArray < Array
  def initialize(class_name)
    @class_name = class_name
  end
  def to_fxml(*args) # You need the *args so that it doesn't fail if there are :include or :methods params
    empty? ? "<#{@class_name} type=\"array\"/>" : super.to_fxml
  end
end

module ActiveSupport
  module CoreExtensions
    module Hash
      module Conversions
        def to_fxml(options = {})
          options.merge!(:dasherize => false)
          to_xml(options)
        end
      end
    end
    module Array
      module Conversions
        def to_fxml(options = {})
          options.merge!(:dasherize => false)
          to_xml(options)
        end
      end
    end
  end
end

module ActiveRecord
  # Flex friendly XML serialization patches
  class Base
    class << self
      alias_method :old_find, :find unless method_defined?(:old_find)

      def find(*args)
        result = old_find(*args)
        if result.class == Array and result.empty?
          result = ClassyEmptyArray.new(self.class_name.tableize)
        end
        result
      end

      # TODO: this doesn't work with hash based to_fxml(:include) options, only array based
      def default_fxml_methods(*args)
        methods = *args.dup
        module_eval <<-END 
            def self.default_fxml_methods_array
              return [#{methods.inspect}].flatten
            end
          END
      end
      
      def default_fxml_includes(*args)
        includes = *args.dup
        module_eval <<-END
          def self.default_fxml_include_params
            return [#{includes.inspect}].flatten
          end
        END
      end
            
      def default_fxml_hash(already_included = [])
        # return {} unless self.class.respond_to?(:default_fxml_include_params) || self.class.respond_to?(:default_fxml_methods_array)
        default_hash = {:include => {}}
        default_hash[:methods] = self.default_fxml_methods_array if self.respond_to?(:default_fxml_methods_array)
        if self.respond_to?(:default_fxml_include_params)
          default_includes = self.default_fxml_include_params
          default_hash[:include] = default_includes.inject({}) do |include_hash, included|
            next if already_included.include?(included) # We only want to include things once, to avoid infinite loops
            included_class = included.to_s.singularize.camelize.constantize
            include_hash[included] = included_class.default_fxml_hash(already_included + default_includes) 
            include_hash
          end
        end
        default_hash
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
        when includes.is_a?(Symbol)
          {includes => {}} 
        else #Deal with arrays and symbols
          puts "creating the hash"
          res = [includes].flatten.inject({}) {|include_hash, included| include_hash[included] = {} ; include_hash}
      end
      res
    end           
      
    end
  end

  module Serialization
    def to_fxml(options = {})
      options.merge!(:dasherize => false)
      default_except = [:crypted_password, :salt, :remember_token, :remember_token_expires_at]
      options[:except] = (options[:except] ? options[:except] + default_except : default_except)
      options[:methods] = [options[:methods] || []].flatten + (self.class.default_fxml_hash[:methods] || [])
      options[:include] = self.class.default_fxml_hash[:include].merge(self.class.includes_as_hash(options[:include]))
      to_xml(options)
    end
    
  end

  # Change the xml serializer so that '?'s are stripped from attribute names.
  # This makes it possible to serialize methods that end in a question mark, like 'valid?' or 'is_true?'
  class XmlSerializer
    def add_tag(attribute)
      builder.tag!(
        dasherize? ? attribute.display_name.dasherize : attribute.display_name,
        attribute.value.to_s,
        attribute.decorations(!options[:skip_types])
      )
    end    
    class Attribute
      def display_name
        @name.gsub('?','')
      end
    end
  end

  # Add more extensive reporting on errors including field name along with a message
  # when errors are serialized to XML
  class Errors
    def to_fxml(options={})
      options[:root] ||= "errors"
      options[:indent] ||= 2
      options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
      options[:builder].instruct! unless options.delete(:skip_instruct)
      options[:builder].errors do |e|
        # The @errors instance variable is a Hash inside the Errors class
        @errors.each_key do |attr|
          @errors[attr].each do |msg|
            next if msg.nil?
            if attr == "base"
              options[:builder].error("message" => msg)
            else
              fullmsg = @base.class.human_attribute_name(attr) + ' ' + msg
              options[:builder].error("field" => attr.camelcase(:lower), "message" => fullmsg)
            end
          end
        end
      end
    end  
  end
end