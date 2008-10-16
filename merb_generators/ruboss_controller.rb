require 'ruboss4ruby/configuration'

module Merb::Generators
  class RubossControllerGenerator < Generator
    include Ruboss::Configuration
    
    def initialize(*args)
      super
      @project_name, @flex_project_name, @command_controller_name, @base_package, @base_folder = extract_names
    end

    def project_name
      @project_name
    end

    def flex_project_name
      @flex_project_name
    end

    def base_folder
      @base_folder
    end
    
    def base_package
      @base_package
    end
    
    def command_controller_name
      @command_controller_name
    end
    
    def model_names
      list_as_files("app/flex/#{base_folder}/models")
    end
    
    def command_names
      list_as_files("app/flex/#{base_folder}/commands")
    end

    def self.source_root
      File.join(File.dirname(__FILE__), 'templates', 'ruboss_controller')
    end
    
    template :controller do |t|
      t.source = 'controller.as.erb'
      t.destination = File.join('app', 'flex', base_folder, 'controllers', "#{command_controller_name}.as")
    end

    desc <<-DESC
      Generates the main Ruboss Flex application controller.
      Typically app/flex/<yourappname>/controllers/<YourAppName>Controller.as, 
      e.g. app/flex/pomodo/controllers/PomodoController.as
    
      It pulls out all available models and commands from respective
      folders and makes sure they'll be pulled into the Flex application
      at runtime.
    DESC
  end
  
  add :ruboss_controller, RubossControllerGenerator
end