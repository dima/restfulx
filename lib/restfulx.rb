# Sets up all the relevant configuration options and brings together 
# patches for Rails, Merb, ActiveRecord and Data Mapper.
#
# Loads RestfulX specific rake tasks if appropriate.
module RestfulX
  module Types
    APPLICATION_AMF = 'application/x-amf'.freeze
    APPLICATION_FXML = 'application/xml'.freeze
  end
  
  FRAMEWORK_VERSION = '1.3.0'
  LIB_DIR = File.join(File.dirname(__FILE__), 'restfulx/')
end

['configuration', 'amf'].each { |lib| require RestfulX::LIB_DIR + lib }

# make sure we're running inside Merb
if defined?(Merb::Plugins)
  Merb::Plugins.add_rakefiles RestfulX::LIB_DIR + 'tasks'

  Merb::BootLoader.before_app_loads do
    Merb.add_mime_type(:amf,  :to_amf, RestfulX::APPLICATION_AMF, :charset => "utf-8")

    if defined?(ActiveRecord::Base)
      ['active_support', 'active_model', 'active_record'].each { |lib| require RestfulX::LIB_DIR + lib }
      ActiveRecord::Base.send :include, RestfulX::ActiveRecord::Serialization
      ActiveModel::Errors.send :include, RestfulX::ActiveModel::Errors
      ActiveModel.send :include, RestfulX::ActiveModel::Serializers
      
      Merb.add_mime_type(:fxml,  :to_fxml,  %w[application/xml text/xml application/x-xml], :charset => "utf-8")
      
      Merb::Plugins.add_rakefiles RestfulX::LIB_DIR + 'active_record_tasks'
    else
      Merb.add_mime_type(:fxml,  :to_xml,  %w[application/xml text/xml application/x-xml], :charset => "utf-8")
      if defined?(Merb::Orms::DataMapper)
        require RestfulX::LIB_DIR + 'datamapper'
      end
    end
  end    
elsif defined?(ActionController::Base)
  # if we are not running in Merb, try to hook up Rails
  Mime::Type.register_alias RestfulX::Types::APPLICATION_FXML, :fxml
  Mime::Type.register RestfulX::Types::APPLICATION_AMF, :amf
  
  ['active_support', 'active_model', 'active_record', 'action_controller', 'swf_helper'].each { |lib| require RestfulX::LIB_DIR + lib }

  ActionController::Base.send :include, RestfulX::ActionController
  
  ActiveRecord::Base.send :include, RestfulX::ActiveRecord::Serialization
  ActiveModel::Errors.send :include, RestfulX::ActiveModel::Errors
  ActiveModel.send :include, RestfulX::ActiveModel::Serializers
  
  ActionView::Base.send :include, SWFHelper unless ActionView::Base.included_modules.include?(SWFHelper)
elsif defined?(DataMapper)
  require RestfulX::LIB_DIR + 'datamapper'
elsif defined?(ActiveRecord::Base)
  ['active_support', 'active_model', 'active_record'].each { |lib| require RestfulX::LIB_DIR + lib }
  ActiveRecord::Base.send :include, RestfulX::ActiveRecord::Serialization
  ActiveModel::Errors.send :include, RestfulX::ActiveModel::Errors
  ActiveModel.send :include, RestfulX::ActiveModel::Serializers
end