require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'restfulx') if !defined?(RestfulX)

module Rails
  module Generator
    module Commands
      class Create
        include SchemaToRxYaml
      end
    end
  end
end

class RxMainAppGenerator < Rails::Generator::Base
  include RestfulX::Configuration
  
  attr_reader :project_name, 
              :flex_project_name, 
              :base_package, 
              :base_folder, 
              :command_controller_name,
              :model_names, 
              :component_names,
              :controller_names,
              :use_air,
              :application_tag,
              :flex_root,
              :distributed

  def initialize(runtime_args, runtime_options = {})
    super
    @project_name, @flex_project_name, @command_controller_name, @base_package, @base_folder,
      @flex_root, @distributed = extract_names

    project_file_name = APP_ROOT + '/.project'
    if File.exist?(project_file_name)
      @use_air = true if File.read(project_file_name) =~/com.adobe.flexbuilder.apollo.apollobuilder/m
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
      m.template 'mainapp.mxml', File.join("#{flex_root}", "#{flex_project_name}.mxml"), :collision => options[:collision]
    end
  end

  def banner
    "Usage: #{$0} #{spec.name}" 
  end
end