#ActiveRecord+ActiveSupport specific patches

# Flex friendly date, datetime formats
ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(:flex => "%Y/%m/%d")
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(:flex => "%Y/%m/%d %H:%M:%S")

Hash::XML_FORMATTING['date'] = Proc.new { |date| date.to_s(:flex) }
Hash::XML_FORMATTING['datetime'] = Proc.new { |datetime| datetime.to_s(:flex) }

class ClassyEmptyArray < Array
  def initialize(class_name)
    @class_name = class_name
  end
  def to_fxml
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
      alias_method :old_find, :find

      def find(*args)
        result = old_find(*args)
        if result.class == Array and result.empty?
          result = ClassyEmptyArray.new(self.class_name.tableize)
        end
        result
      end
    end
  end

  module Serialization
    def to_fxml(options = {})
      options.merge!(:dasherize => false)
      default_except = [:crypted_password, :salt, :remember_token, :remember_token_expires_at]
      options[:except] = (options[:except] ? options[:except] + default_except : default_except)
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
              options[:builder].error("field" => attr, "message" => fullmsg)
            end
          end
        end
      end
    end  
  end
end