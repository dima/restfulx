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
              :use_air

  def initialize(runtime_args, runtime_options = {})
    super
    @project_name, @flex_project_name, @command_controller_name, @base_package, @base_folder = extract_names
    
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
    if File.exists?("app/flex/#{base_folder}/components/generated")
      @component_names = list_mxml_files("app/flex/#{base_folder}/components/generated")
    end
  end

  def manifest
    record do |m|
      if !options[:main_only]
        m.file 'restfulx_tasks.rake', 'lib/tasks/restfulx_tasks.rake'
        m.file 'flex.properties', '.flexProperties'
        m.file 'restfulx.yml', 'config/restfulx.yml'
        if @use_air
          m.template 'actionscriptair.properties', '.actionScriptProperties'
          m.template 'projectair.properties', '.project'
        else
          m.template 'actionscript.properties', '.actionScriptProperties'
          m.template 'project.properties', '.project'
        end
  
        m.directory 'html-template/history'      
        %w(index.template.html AC_OETags.js playerProductInstall.swf).each do |file|
          m.file "html-template/#{file}", "html-template/#{file}"
        end
        
        %w(history.css history.js historyFrame.html).each do |file|
          m.file "html-template/history/#{file}", "html-template/history/#{file}"
        end
        
        %w(components controllers commands models events).each do |dir|
          m.directory "app/flex/#{base_folder}/#{dir}"
        end
        
        m.directory "app/flex/#{base_folder}/components/generated"
        
        framework_release = RestfulX::FRAMEWORK_VERSION
        framework_distribution_url = "http://restfulx.github.com/releases/restfulx-#{framework_release}.swc"
        framework_destination_file = "lib/restfulx-#{framework_release}.swc"
        
        if !options[:skip_framework] && !File.exist?(framework_destination_file)
          puts "fetching #{framework_release} framework binary from: #{framework_distribution_url} ..."
          open(framework_destination_file, "wb").write(open(framework_distribution_url).read)
          puts "done. saved to #{framework_destination_file}"
        end
  
        m.file 'swfobject.js', 'public/javascripts/swfobject.js'
        m.file 'expressInstall.swf', 'public/expressInstall.swf'
        
        m.file 'flex_controller.erb', 'app/controllers/flex_controller.rb'
        
        m.directory "app/views/flex"
        
        m.template 'index.erb', 'app/views/flex/index.html.erb'
        
        m.file 'routes.erb', 'config/routes.rb', :collision => :force
        
        FileUtils.rm 'public/index.html' if File.exist?('public/index.html')
                
        m.dependency 'rx_controller', @args
      end
      m.template 'project-textmate.erb', "#{project_name.underscore}.tmproj"
      m.template 'mainapp.mxml', File.join('app/flex', "#{project_name}.mxml")
      m.template 'mainapp-config.xml', File.join('app/flex', "#{project_name}-config.xml")
      m.template 'mainair-app.xml', File.join('app/flex', "#{project_name}-app.xml") if @use_air
    end
  end

  protected
  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("-m", "--main-only", "Only generate the main Flex/AIR application file.", 
      "Default: false") { |v| options[:main_only] = v }
    opt.on("-a", "--air", "Configure AIR project instead of Flex. Flex is default.", 
      "Default: false") { |v| options[:air_config] = v }
    opt.on("--skip-framework", "Don't fetch the latest framework binary. You'll have to link/build the framework yourself.", 
      "Default: false") { |v| options[:skip_framework] = v }
  end

  def banner
    "Usage: #{$0} #{spec.name}" 
  end
end