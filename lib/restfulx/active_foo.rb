# There's a number of things that ActiveRecord/ActiveSupport and the rest of the family get
# ~wrong~ from the point of view of Flex clients.
#
# Some of these things are:
# * XML format (Flex *really* doesn't like dashes in XML messages)
# * Errors (we need to be more specific and communicate what went wrong *where*) 
#
# This is where we try to fix this stuff.
#
# Some of the things that are done can be called _monkey_ _patching_ while others can
# be called extensions. Caveat emptor.

# ActiveSupport specific patches. More specifically we add +to_fxml+ methods to Array and
# Hash conversion modules
module ActiveSupport
  # refer to: http://api.rubyonrails.org/ for more details
  module CoreExtensions
    # Add Flex friendly +to_fxml+ to Hash conversions
    module Hash
      # refer to: http://api.rubyonrails.org/ for more details
      module Conversions
        
        # Flex friendly XML format, no dashes, etc
        def to_fxml(options = {})
          options.merge!(:dasherize => false)
          options[:indent] ||= 2
          options.reverse_merge!({ :builder => Builder::XmlMarkup.new(:indent => options[:indent]),
                                   :root => "hash" })
          options[:builder].instruct! unless options.delete(:skip_instruct)
          dasherize = !options.has_key?(:dasherize) || options[:dasherize]
          root = dasherize ? options[:root].to_s.dasherize : options[:root].to_s

          options[:builder].__send__(:method_missing, root) do
            each do |key, value|
              case value
                when ::Hash
                  value.to_fxml(options.merge({ :root => key, :skip_instruct => true }))
                when ::Array
                  value.to_fxml(options.merge({ :root => key, :children => key.to_s.singularize, :skip_instruct => true}))
                when ::Method, ::Proc
                  # If the Method or Proc takes two arguments, then
                  # pass the suggested child element name.  This is
                  # used if the Method or Proc will be operating over
                  # multiple records and needs to create an containing
                  # element that will contain the objects being
                  # serialized.
                  if 1 == value.arity
                    value.call(options.merge({ :root => key, :skip_instruct => true }))
                  else
                    value.call(options.merge({ :root => key, :skip_instruct => true }), key.to_s.singularize)
                  end
                else
                  if value.respond_to?(:to_fxml)
                    value.to_fxml(options.merge({ :root => key, :skip_instruct => true }))
                  else
                    type_name = XML_TYPE_NAMES[value.class.name]

                    key = dasherize ? key.to_s.dasherize : key.to_s

                    attributes = options[:skip_types] || value.nil? || type_name.nil? ? { } : { :type => type_name }
                    if value.nil?
                      attributes[:nil] = true
                    end

                    options[:builder].tag!(key,
                      XML_FORMATTING[type_name] ? XML_FORMATTING[type_name].call(value) : value,
                      attributes
                    )
                end
              end
            end
    
            yield options[:builder] if block_given?
          end
        end
      end
    end
    # Add Flex friendly to_fxml to array conversions
    module Array
      # refer to: http://api.rubyonrails.org/ for more details
      module Conversions
        # Flex friendly XML format (no dashes, etc)
        def to_fxml(options = {})
          raise "Not all elements respond to to_fxml" unless all? { |e| e.respond_to? :to_fxml }

          options[:root]     ||= all? { |e| e.is_a?(first.class) && first.class.to_s != "Hash" } ? first.class.to_s.underscore.pluralize : "records"
          options[:children] ||= options[:root].singularize
          options[:indent]   ||= 2
          options[:builder]  ||= Builder::XmlMarkup.new(:indent => options[:indent])
          options.merge!(:dasherize => false)
          
          options[:attributes] ||= {}
          options[:attributes].merge!(:type => "array")

          root     = options.delete(:root).to_s
          children = options.delete(:children)

          if !options.has_key?(:dasherize) || options[:dasherize]
            root = root.dasherize
          end

          options[:builder].instruct! unless options.delete(:skip_instruct)

          opts = options.merge({ :root => children })

          xml = options[:builder]
          if empty?
            xml.tag!(root, options[:attributes])
          else
            xml.tag!(root, options[:attributes]) {
              yield xml if block_given?
              each { |e| e.to_fxml(opts.merge!({ :skip_instruct => true })) }
            }
          end
        end
      end
    end
  end
end

# Flex friendly ActiveRecord patches. More specifically XML serialization improvements.
# These won't override whatever you may normally do with XML, hence there's Flex specific
# name for this stuff +to_fxml+.
module ActiveRecord
  # refer to: http://api.rubyonrails.org/ for more details
  module Serialization
    # Enforces Flex friendly options on XML and delegates processing to standard +to_xml+
    def to_fxml(options = {}, &block)
      options.merge!(:dasherize => false)
      default_except = [:crypted_password, :salt, :remember_token, :remember_token_expires_at]
      options[:except] = (options[:except] ? options[:except] + default_except : default_except)
      to_xml(options, &block)
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
  # when errors are serialized to XML
  class Errors
    # Flex friendly errors
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
              fullmsg = @base.class.human_attribute_name(attr) + ' ' + msg.to_s
              options[:builder].error("field" => attr.camelcase(:lower), "message" => fullmsg)
            end
          end
        end
      end
    end  
  end
end