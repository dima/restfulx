################################################################################
# Copyright 2008, Ruboss Technology Corporation.
#
# This software is dual-licensed under both the terms of the Ruboss Commercial
# License v1 (RCL v1) as published by Ruboss Technology Corporation and under
# the terms of the GNU General Public License v3 (GPL v3) as published by the
# Free Software Foundation.
#
# Both the RCL v1 (rcl-1.0.txt) and the GPL v3 (gpl-3.0.txt) are included in
# the source code. If you have purchased a commercial license then only the
# RCL v1 applies; otherwise, only the GPL v3 applies. To learn more or to buy a
# commercial license, please go to http://ruboss.com.
################################################################################
require 'open-uri'
require 'fileutils'
require 'ruboss_on_ruby/version'
require 'ruboss_on_ruby/configuration'

class RubossConfigGenerator < Merb::GeneratorBase
  include RubossOnRuby::Configuration

  default_options :main_only => false, :air_config => false, :skip_framework => false
    
  attr_reader :project_name, 
              :flex_project_name, 
              :base_package, 
              :base_folder, 
              :command_controller_name, 
              :component_names, 
              :application_tag,
              :use_air

  def initialize(runtime_args, runtime_options = {})
    runtime_args.push ""
    super
    
    @project_name, @flex_project_name, @command_controller_name, @base_package, @base_folder = extract_names
    
    # if we updating main file only we probably want to maintain the type of project it is
    if options[:main_only]
      project_file_name = APP_ROOT + '/.project'
      if File.exist?(project_file_name)
        puts "Cannot combine -m (--main-app) and -a (--air) flags at the same time for an existing application.\n" << 
          'If you want to convert to AIR, remove -m flag.' if options[:air_config]
        @use_air = true if File.read(project_file_name) =~/com.adobe.flexbuilder.apollo.apollobuilder/m
      else
        puts "Flex Builder project file doesn't exist. You should run 'ruboss_config' with -a (--air) option or " <<
          "no arguments first to generate primary project structure."
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
        m.directory 'public/bin'
        m.directory 'public/javascripts'
        m.directory 'schema'
        
        m.file 'flex.properties', '.flexProperties'
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
                
        framework_release = RubossOnRuby::RUBOSS_FRAMEWORK_VERSION
        framework_distribution_url = "http://ruboss.com/releases/ruboss-#{framework_release}.swc"
        framework_destination_file = "lib/ruboss-#{framework_release}.swc"
        
        if !options[:skip_framework] && !File.exist?(framework_destination_file)
          FileUtils.mkdir('lib') unless File.directory?('lib')
          puts "fetching #{framework_release} framework binary from: #{framework_distribution_url} ..."
          open(framework_destination_file, "wb").write(open(framework_distribution_url).read)
          puts "done. saved to #{framework_destination_file}"
        end
  
        m.file 'swfobject.js', 'public/javascripts/swfobject.js'
        m.file 'expressInstall.swf', 'public/expressInstall.swf'
        m.template 'index.html.erb', 'app/views/layout/application.html.erb'
        
        m.dependency 'ruboss_controller', @args
      end
      m.template 'mainapp.mxml', File.join('app/flex', "#{project_name}.mxml")
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
      opt.on("-s", "--skip-framework", "Don't fetch the latest framework binary. You'll have to link/build the framework yourself.", 
        "Default: false") { |v| options[:skip_framework] = v }
    end

    def banner
      "Usage: #{$0} #{spec.name}" 
    end
end