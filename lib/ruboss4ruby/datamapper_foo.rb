require 'builder'
require Ruboss4Ruby::LIB_DIR + 'configuration'

# Flex friendly DataMapper patches, more specifically we just add +to_xml+ on 
# ValidationErrors class
module DataMapper
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