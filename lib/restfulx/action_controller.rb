module RestfulX::ActionController
  def self.included(base)
    base.class_eval do
      alias_method_chain :render, :amf
      alias_method_chain :render, :fxml
    end
  end
  
  def render_with_amf(options=nil, extra_options={}, &block)
    if Hash === options and options.key?(:amf)
      object = options.delete(:amf)
      unless String === object
        object = object.to_amf(options, &block) if object.respond_to?(:to_amf)
      end
      render_without_amf(:text => object, :content_type => RestfulX::Types::APPLICATION_AMF)
    else
      render_without_amf(options, extra_options, &block)
    end
  end
  
  def render_with_fxml(options=nil, extra_options={}, &block)
    if Hash === options and options.key?(:fxml)
      object = options.delete(:fxml)
      unless String === object
        object = object.to_fxml(options, &block) if object.respond_to?(:to_fxml)
      end
      render_without_fxml(:text => object, :content_type => RestfulX::Types::APPLICATION_FXML)
    else
      render_without_fxml(options, extra_options, &block)
    end
  end
end