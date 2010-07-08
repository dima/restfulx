require 'open-uri'
require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'restfulx') if !defined?(RestfulX)

class RxConfigGenerator < Rails::Generator::Base
  include RestfulX::Configuration
    
  attr_reader :project_name, 
              :flex_project_name, 
              :base_package, 
              :base_folder, 
              :command_controller_name, 
              :component_names, 
              :application_tag,
              :use_air,
              :flex_root,
              :base_flex_package,
              :distributed

  def initialize(runtime_args, runtime_options = {})
    super
    @project_name, @flex_project_name, @command_controller_name, @base_package, @base_folder, 
      @flex_root = extract_names
    
    @base_package = options[:base_flex_package] if options[:base_flex_package]
    @base_folder = options[:base_flex_package].gsub('.', '/') if options[:base_flex_package]
    @flex_root = options[:flex_root] if options[:flex_root]
    @distributed = options[:distributed]
    
    # if we are updating main file only we probably want to maintain the type of project it is
    if options[:main_only]
      project_file_name = APP_ROOT + '/.project'
      if File.exist?(project_file_name)
        puts "Cannot combine -m (--main-app) and -a (--air) flags at the same time for an existing application.\n" << 
          'If you want to convert to AIR, remove -m flag.' if options[:air_config]
        @use_air = true if File.read(project_file_name) =~/com.adobe.flexbuilder.apollo.apollobuilder/m
      else
        puts "Flex Builder project file doesn't exist. You should run 'rx_config' with -a (--air) option " <<
         "or no arguments first to generate primary project structure."
        exit 0;
      end
    else
      @use_air = options[:air_config]
    end
                    
    if @use_air
      @application_tag = 'WindowedApplication'
    else
      @application_tag = 'Application'
    end
        
    @component_names = []
    if File.exists?("#{flex_root}/#{base_folder}/views/generated")
      @component_names = list_mxml_files("#{flex_root}/#{base_folder}/views/generated")
    end
  end

  def manifest
    record do |m|
      m.file 'restfulx_tasks.rake', 'lib/tasks/restfulx_tasks.rake' if !options[:skip_tasks]
      m.file 'flex.properties', '.flexProperties'
      m.template 'restfulx.yml', 'config/restfulx.yml'
      m.template 'restfulx.erb', 'config/initializers/restfulx.rb'
      
      m.template 'session_store_flash.erb', 'config/initializers/session_store_flash.rb' if RAILS_GEM_VERSION =~ /2.3/
      
      m.directory "#{flex_root}"
      
      if @use_air
        m.template 'actionscriptair.properties', '.actionScriptProperties'
        m.template 'projectair.properties', '.project'
      else
        m.template 'actionscript.properties', '.actionScriptProperties'
        m.template 'project.properties', '.project'
      end
      
      m.template 'project-textmate.erb', "#{project_name}.tmproj"
      m.template 'mainapp.mxml', File.join("#{flex_root}", "#{flex_project_name}.mxml")
      m.template 'mainapp-config.xml', File.join("#{flex_root}", "#{flex_project_name}-config.xml")
      m.template 'mainair-app.xml', File.join("#{flex_root}", "#{flex_project_name}-app.xml") if @use_air

      m.directory 'html-template/history'      
      %w(index.template.html AC_OETags.js playerProductInstall.swf).each do |file|
        m.file "html-template/#{file}", "html-template/#{file}"
      end
      
      %w(history.css history.js historyFrame.html).each do |file|
        m.file "html-template/history/#{file}", "html-template/history/#{file}"
      end
      
      %w(views controllers commands models events helpers).each do |dir|
        m.directory "#{flex_root}/#{base_folder}/#{dir}"
      end
      
      m.directory "#{flex_root}/#{base_folder}/views/generated"
      
      framework_release = RestfulX::VERSION
      framework_distribution_url = "http://restfulx.github.com/releases/restfulx-#{framework_release}.swc"
      framework_destination_file = "lib/restfulx-#{framework_release}.swc"
      
      if !options[:skip_framework] && !File.exist?(framework_destination_file)
        puts "Fetching #{framework_release} framework binary from: #{framework_distribution_url} ..."
        begin
          framework_swc = open(framework_distribution_url).read
        rescue
          puts "ERROR: Unable to download and install #{framework_distribution_url}."
          puts "Please check your internet connectivity and try again."
          exit
        end
        open(framework_destination_file, "wb").write(framework_swc) unless framework_swc.blank?
        puts "done. saved to #{framework_destination_file}"
      end

      m.file 'swfobject.js', 'public/javascripts/swfobject.js'
      m.file 'expressInstall.swf', 'public/expressInstall.swf'
      
      m.file 'flex_controller.erb', 'app/controllers/flex_controller.rb'
      
      m.directory "app/views/flex"
      
      m.template 'index.erb', 'app/views/flex/index.html.erb'
      
      m.file 'routes.erb', 'config/routes.rb', :collision => options[:collision]
      
      FileUtils.rm 'public/index.html' if File.exist?('public/index.html')
              
      m.dependency 'rx_controller', @args
    end
  end

  protected
  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("-a", "--air", "Configure AIR project instead of Flex. Flex is default.", 
      "Default: false") { |v| options[:air_config] = v }
    opt.on("--skip-framework", "Don't fetch the latest framework binary. You'll have to link/build the framework yourself.", 
      "Default: false") { |v| options[:skip_framework] = v }
    opt.on("--skip-tasks", "Don't install restfulx gem tasks hook into the project.", 
      "Default: false") { |v| options[:skip_tasks] = v }
    opt.on("--flex-root [FOLDER]", "Root folder for generated flex code.", 
      "Default: app/flex") { |v| options[:flex_root] = v }
    opt.on("--base-flex-package [PACKAGE]", "Base package for your application.", 
      "Default: #{flex_project_name}") { |v| options[:base_flex_package] = v }
    opt.on("--distributed", "Creates migrations, controllers and models that use UUIDs and are distribution ready", 
      "Default: false") { |v| options[:distributed] = v }
  end

  def banner
    "Usage: #{$0} #{spec.name}" 
  end
end