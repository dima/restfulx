$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'yaml'
require 'restfulx/configuration'

# Settings
module RestfulX  
  module Types
    APPLICATION_FXML = 'application/xml'.freeze
    APPLICATION_AMF = 'application/x-amf'.freeze
  end
  
  def self.amf_serializer
    @amf_serializer
  end
  
  def self.amf_serializer=(value)
    @amf_serializer = value
  end

  VERSION_SOURCE = YAML.load(File.read(File.join(File.dirname(__FILE__), '..', 'VERSION.yml')))
  VERSION = "#{VERSION_SOURCE[:major]}.#{VERSION_SOURCE[:minor]}.#{VERSION_SOURCE[:patch]}"
end

# ActiveRecord extensions
if defined?(ActiveRecord::Base)
  ['active_support', 'active_record'].each { |lib| require "restfulx/#{lib}" }
  ActiveRecord::Base.send :include, 
    RestfulX::ActiveRecord unless ActiveRecord::Base.included_modules.include?(RestfulX::ActiveRecord)
end

# ActionController/ActionView extensions
if defined?(ActionController::Base)
  Mime::Type.register_alias RestfulX::Types::APPLICATION_FXML, :fxml
  Mime::Type.register RestfulX::Types::APPLICATION_AMF, :amf
  
  ['action_controller', 'swf_helper'].each { |lib| require "restfulx/#{lib}" }

  ActionController::Base.send :include, 
    RestfulX::ActionController unless ActionController::Base.included_modules.include?(RestfulX::ActionController)
  ActionView::Base.send :include, 
    RestfulX::SWFHelper unless ActionView::Base.included_modules.include?(RestfulX::SWFHelper)
end

# DataMapper extensions
if defined?(DataMapper)
  require 'restfulx/datamapper'
end