$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'erb'
require 'schema_to_rx_yaml' if !defined?(SchemaToRxYaml)

# Enumerable extensions
module Enumerable
  # Helps you find duplicates
  # used in schema_to_yaml.rb for cleanup
  def dups
    inject({}) { |h,v| h[v] = h[v].to_i + 1; h }.reject{ |k,v| v == 1 }.keys
  end
end

# Interestingly enough there's no way to *just* upper-case or down-case first letter of a given
# string. Ruby's own +capitalize+ actually downcases all the rest of the characters in the string
# We patch the class to add our own implementation.
class String
  # Upper-case first character of a string leave the rest of the string intact
  def ucfirst
    self[0,1].capitalize + self[1..-1]
  end
  
  # Down-case first character of a string leaving the rest of it intact
  def dcfirst
    self[0,1].downcase + self[1..-1]
  end
end

# Primary RestfulX configuration options
module RestfulX
  # Computes necessary configuration options from the environment. This can be used in Rails
  # or standalone from the command line.
  module Configuration
    # We try to figure out the application root using a number of possible options
    APP_ROOT = defined?(RAILS_ROOT) ? RAILS_ROOT : File.expand_path(".")
    
    RxSettings = SchemaToRxYaml::Settings::Core

    # Extract project, package, controller name, etc from the environment. This will respect
    # config/restfulx.yml if it exists, you can override all of the defaults there.
    def extract_names(project = nil)
      if project
        project_name = project.downcase.gsub(/\W/, '')
        flex_project_name = project_name.camelize
      else
        project_name = APP_ROOT.split("/").last.gsub(/\W/, '')
        flex_project_name = project_name.camelize
      end
            
      # give a chance to override the settings via restfulx.yml
      begin      
        config = YAML.load(File.open("#{APP_ROOT}/config/restfulx.yml"))
        base_package = config['base_package'] || flex_project_name.downcase
        base_folder = base_package.gsub('.', '/')
        project_name = config['project_name'].downcase.gsub(/\W/, '') || project_name
        flex_project_name = project_name.camelize
        controller_name = config['controller_name'] || "ApplicationController"
        flex_root = config['flex_root'] || "app/flex"
        distributed = config['distributed'] || false
      rescue
        base_folder = base_package = flex_project_name.downcase
        controller_name = "ApplicationController"
        flex_root = "app/flex"
        distributed = false
      end
      [project_name, flex_project_name, controller_name, base_package, base_folder, flex_root, distributed]
    end

    # List files ending in *.as (ActionScript) in a given folder
    def list_as_files(dir_name)
      Dir.entries(dir_name).grep(/\.as$/).map { |name| name.sub(/\.as$/, "") }.join(", ")
    end

    # List files ending in *.mxml in a given folder
    def list_mxml_files(dir_name)
      Dir.entries(dir_name).grep(/\.mxml$/).map { |name| name.sub(/\.mxml$/, "") }
    end
  end
end