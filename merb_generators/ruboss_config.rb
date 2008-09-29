require 'open-uri'
require 'fileutils'
require 'ruboss4ruby/version'
require 'ruboss4ruby/configuration'

module Merb::Generators
  class RubossConfigGenerator < Generator
    include Ruboss::Configuration

    option :air, :as => :boolean, :default => false, :desc => 'Configure AIR project instead of Flex. Flex is default.'
    option :skip_framework, :as => :boolean, :default => false, :desc => "Don't fetch the latest framework binary. You'll have to link/build the framework yourself."
    
    def initialize(*args)
      super
      @project_name, @flex_project_name, @command_controller_name, @base_package, @base_folder = extract_names
    
      framework_release = Ruboss::RUBOSS_FRAMEWORK_VERSION
      framework_distribution_url = "http://ruboss.com/releases/ruboss-#{framework_release}.swc"
      framework_destination_file = "lib/ruboss-#{framework_release}.swc"
      
      if !get_option(:skip_framework) && !File.exist?(framework_destination_file)
        FileUtils.mkdir('lib') unless File.directory?('lib')
        puts "fetching #{framework_release} framework binary from: #{framework_distribution_url} ..."
        open(framework_destination_file, "wb").write(open(framework_distribution_url).read)
        puts "done. saved to #{framework_destination_file}"
      end
    end
    
    def extract_config(config_file)
      if get_option(:air)
        config_file << 'air'
      end
      config_file
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

    def self.source_root
      File.join(File.dirname(__FILE__), 'templates', 'ruboss_config')
    end

    desc <<-DESC
      Generates the primary Ruboss directory structure. 
      Sets up Flex Builder specific descriptor files and options fetches 
      the latest published Ruboss Framework SWC file.
    DESC

    empty_directory :bin, File.join('public', 'bin')
    empty_directory :javascripts, File.join('public', 'javascripts')
    empty_directory :schema, 'schema'
    
    file :flex_properties, 'flex.properties', '.flexProperties'
    
    template :actionscript_properties do
      source("#{extract_config('actionscript')}.properties")
      destination('.actionScriptProperties')
    end
    
    template :project_properties do
      source("#{extract_config('project')}.properties")
      destination('.project')
    end
    
    %w(components controllers commands models events).each do |dir|
      empty_directory dir.to_sym do
        destination(File.join('app', 'flex', base_folder, dir))
      end
    end
    
    empty_directory :generated do
       File.join('app', 'flex', base_folder, 'components', 'generated')
    end
    
    glob!('html-template')
    
    file :swfoject, 'swfobject.js', File.join('public', 'javascripts', 'swfobject.js')
    
    file :express_install, 'expressInstall.swf', File.join('public', 'expressInstall.swf')
    
    file :ruboss_yml, 'ruboss.yml', File.join('config', 'ruboss.yml')
    
    template :index, 'index.html.erb', File.join('app', 'views', 'layout', 'application.html.erb')
    
    invoke :ruboss_flex_app

    template :air_descriptor, :air => true do
      source('mainair-app.xml')
      destination(File.join('app', 'flex', "#{project_name}-app.xml"))
    end
    
    invoke :ruboss_controller
  end
  
  add :ruboss_config, RubossConfigGenerator
end