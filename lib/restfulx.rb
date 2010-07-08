require 'yaml'

# Settings
module RestfulX
  module Types
    APPLICATION_FXML = 'application/xml'.freeze
    APPLICATION_AMF = 'application/x-amf'.freeze
  end

  VERSION_SOURCE = YAML.load(File.read(File.join(File.dirname(__FILE__), '..', 'VERSION.yml')))
  VERSION = "#{VERSION_SOURCE[:major]}.#{VERSION_SOURCE[:minor]}.#{VERSION_SOURCE[:patch]}"
  LIB_DIR = File.join(File.dirname(__FILE__), 'restfulx/')
end

['configuration', 'amf'].each { |lib| require RestfulX::LIB_DIR + lib }

# ActiveRecord extensions
if defined?(ActiveRecord::Base)
  ['active_support', 'active_record'].each { |lib| require RestfulX::LIB_DIR + lib }
  ActiveRecord::Base.send :include, 
    RestfulX::ActiveRecord unless ActiveRecord::Base.included_modules.include?(RestfulX::ActiveRecord)
end

# ActionController/ActionView extensions
if defined?(ActionController::Base)
  Mime::Type.register_alias RestfulX::Types::APPLICATION_FXML, :fxml
  Mime::Type.register RestfulX::Types::APPLICATION_AMF, :amf
  
  ['action_controller', 'swf_helper'].each { |lib| require RestfulX::LIB_DIR + lib }

  ActionController::Base.send :include, 
    RestfulX::ActionController unless ActionController::Base.included_modules.include?(RestfulX::ActionController)
  ActionView::Base.send :include, 
    RestfulX::SWFHelper unless ActionView::Base.included_modules.include?(RestfulX::SWFHelper)
end

# DataMapper extensions
if defined?(DataMapper)
  require RestfulX::LIB_DIR + 'datamapper'
end