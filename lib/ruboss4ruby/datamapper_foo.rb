require 'builder'
require File.join(File.dirname(__FILE__), 'configuration')

module DataMapper
  module Validate
    class ValidationErrors
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