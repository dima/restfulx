class RubossControllerGenerator < RubiGen::Base
  include Ruboss4Ruby::Configuration
  
  attr_reader :project_name, 
              :flex_project_name, 
              :base_package, 
              :base_folder, 
              :command_controller_name,
              :model_names, 
              :command_names

  def initialize(runtime_args, runtime_options = {})
    super
    @project_name, @flex_project_name, @command_controller_name, 
      @base_package, @base_folder = extract_names
    
    @model_names = list_as_files("app/flex/#{base_folder}/models")
    @command_names = list_as_files("app/flex/#{base_folder}/commands")
  end

  def manifest
    record do |m|
      m.template 'controller.as.erb', File.join("app/flex/#{base_folder}/controllers", 
        "#{command_controller_name}.as")
      if options[:gae]
        m.file 'restful.py', 'app/controllers/restful.py' if !File.exist?('app/controllers/restful.py')
        m.file 'assist.py', 'app/models/assist.py' if !File.exist?('app/models/assist.py')
      end
    end
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--gae", "Generate Google App Engine Python classes in addition to Ruboss Flex resources.", 
      "Default: false") { |v| options[:gae] = v }
  end
end
