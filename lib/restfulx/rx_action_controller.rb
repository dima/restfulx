module RestfulX::ActionController
  module Renderers
    def self.included(base)
      base.class_eval do
        add :fxml do |fxml, options|
          self.content_type ||= RestfulX::Types::APPLICATION_FXML
          self.response_body = fxml.respond_to?(:to_fxml) ? fxml.to_fxml(options) : fxml
        end
      
        add :amf do |amf, options|
          self.content_type ||= RestfulX::Types::APPLICATION_AMF
          self.response_body = amf.respond_to?(:to_amf) ? amf.to_amf(options) : amf 
        end
      end
    end
  end
end