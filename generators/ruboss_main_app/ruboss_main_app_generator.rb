class RubossMainAppGenerator < RubiGen::Base
  include Ruboss4Ruby::Configuration
  
  attr_reader :project_name, 
              :flex_project_name, 
              :base_package, 
              :base_folder, 
              :command_controller_name,
              :model_names, 
              :component_names,
              :controller_names,
              :use_air,
              :use_gae,
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
    
    @controller_names = []
    if options[:gae] && File.exists?("app/controllers")
      @use_gae = true
      @controller_names = 
        Dir.entries("app/controllers").grep(/\.py$/).delete_if { |name| name == "__init__.py" }.map { |name| name.sub(/\.py$/, "") }
    end
  end

  def manifest
    record do |m|      
      m.template 'mainapp.mxml', File.join('app', 'flex', "#{project_name}.mxml")
      if options[:gae]
        m.template 'main.py.erb', 'main.py'
      end
    end
  end

  protected
  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("-g", "--gae", "Generate Google App Engine Python classes in addition to Ruboss Flex resources.", 
      "Default: false") { |v| options[:gae] = v }
  end
end
