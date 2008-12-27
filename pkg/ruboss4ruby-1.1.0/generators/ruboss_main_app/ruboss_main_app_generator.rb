class RubossMainAppGenerator < RubiGen::Base
  include Ruboss4Ruby::Configuration
  
  attr_reader :project_name, 
              :flex_project_name, 
              :base_package, 
              :base_folder, 
              :command_controller_name,
              :model_names, 
              :command_names,
              :component_names,
              :use_air,
              :application_tag

  def initialize(runtime_args, runtime_options = {})
    super
    @project_name, @flex_project_name, @command_controller_name, @base_package, @base_folder = extract_names

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
    if File.exists?("app/flex/#{base_folder}/components/generated")
      @component_names = list_mxml_files("app/flex/#{base_folder}/components/generated")
    end
  end

  def manifest
    record do |m|      
      m.template 'mainapp.mxml', File.join('app', 'flex', "#{project_name}.mxml")
    end
  end

  protected
    def banner
      "Usage: #{$0} #{spec.name}" 
    end
end
