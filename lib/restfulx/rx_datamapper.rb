# Flex friendly DataMapper patches, more specifically we just add +to_xml+ on 
# ValidationErrors class
require 'dm-serializer/common'
require 'dm-serializer/xml_serializers'

# RestfulX datamapper patches
module DataMapper
  # Monkey patches dm-serialization to_json method to add ruby_class: YourClass
  # to all serialized objects
  module Serialize
    # Serialize a Resource to JavaScript Object Notation (JSON; RFC 4627)
    #
    # @return <String> a JSON representation of the Resource
    def to_json(*args)
      options = args.first || {}
      result = '{ '
      fields = []

      propset = properties_to_serialize(options)

      fields += propset.map do |property|
        "#{property.name.to_json}: #{send(property.getter).to_json}"
      end
      
      fields << "\"ruby_class\": #{self.class.to_json}"

      # add methods
      (options[:methods] || []).each do |meth|
        if self.respond_to?(meth)
          fields << "#{meth.to_json}: #{send(meth).to_json}"
        end
      end

      # Note: if you want to include a whole other model via relation, use :methods
      # comments.to_json(:relationships=>{:user=>{:include=>[:first_name],:methods=>[:age]}})
      # add relationships
      # TODO: This needs tests and also needs to be ported to #to_xml and #to_yaml
      (options[:relationships] || {}).each do |rel,opts|
        if self.respond_to?(rel)
          fields << "#{rel.to_json}: #{send(rel).to_json(opts)}"
        end
      end

      result << fields.join(', ')
      result << ' }'
      result
    end
  end
    
  # see DataMapper docs for more details
  module Validate
    # By default DataMapper validation errors doesn't have +to_xml+ method. This is
    # actually very useful when dealing with remote stateful clients such as Flex/AIR.
    class ValidationErrors
      # Add Flex-friendly +to_xml+ implementation
      def to_xml
        xml = DataMapper::Serialize::XMLSerializers::SERIALIZER
        doc ||= xml.new_document
        root = xml.root_node(doc, "errors")
        @errors.each_key do |attribute|
          @errors[attribute].each do |msg|
            next if msg.nil?
            if attribute == "base"
              xml.add_node(root, "error", nil, {"message" => msg})
            else
              xml.add_node(root, "error", nil, {"field" => attribute.to_s.camel_case.dcfirst, "message" => msg})
            end
          end
        end
        xml.output(doc)
      end
      
      # Add to_json support for datamapper errors too
      def to_json
        @errors.to_json
      end
    end
  end
end