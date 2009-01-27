require 'builder'
require File.join(File.dirname(__FILE__), '..', 'lib', 'restfulx') if !defined?(RestfulX)

# Flex friendly DataMapper patches, more specifically we just add +to_xml+ on 
# ValidationErrors class
module DataMapper
  
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
        xml = Builder::XmlMarkup.new(:indent => 2)
        xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
        xml.errors do |e|
          @errors.each_key do |attribute|
            @errors[attribute].each do |msg|
              next if msg.nil?
              if attribute == "base"
                e.error("message" => msg)
              else
                e.error("field" => attribute.to_s.camelcase(:lower), "message" => msg)
              end
            end
          end
        end
      end
    end
  end
end