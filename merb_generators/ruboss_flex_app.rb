require 'open-uri'
require 'fileutils'
require 'ruboss4ruby/version'
require 'ruboss4ruby/configuration'

module Merb::Generators
  class RubossFlexAppGenerator < Generator
    include Ruboss::Configuration

    option :air, :as => :boolean, :default => false, :desc => 'Configure AIR project instead of Flex. Flex is default.'
    
    def initialize(*args)
      super
      @project_name, @flex_project_name, @command_controller_name, @base_package, @base_folder = extract_names

      @component_names = []
       if File.exists?("app/flex/#{base_folder}/components/generated")
         @component_names = list_mxml_files("app/flex/#{base_folder}/components/generated")
       end
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
    
    def component_names
      @component_names
    end
    
    def application_tag
      if get_option(:air)
        'WindowedApplication'
      else
        'Application'
      end
    end

    def self.source_root
      File.join(File.dirname(__FILE__), 'templates', 'ruboss_flex_app')
    end

    desc <<-DESC
      Generates main flex application file.
    DESC
    
    template :main_app do
      source('mainapp.mxml')
      destination(File.join('app', 'flex', "#{project_name}.mxml"))
    end
  end
  
  add :ruboss_flex_app, RubossFlexAppGenerator
end