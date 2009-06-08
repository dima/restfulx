class RxAppGenerator < RubiGen::Base
  include RestfulX::Configuration

  attr_reader :project_name, 
              :flex_project_name, 
              :base_package, 
              :base_folder, 
              :command_controller_name, 
              :component_names, 
              :application_tag,
              :use_air,
              :use_gae,
              :flex_root,
              :base_flex_package,
              :distributed

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @destination_root = File.expand_path(args.shift)
    
    @project_name, @flex_project_name, @command_controller_name, 
      @base_package, @base_folder, @flex_root, @distributed = extract_names(base_name)

    @base_package = options[:base_flex_package] if options[:base_flex_package]
    @base_folder = options[:base_flex_package].gsub('.', '/').gsub(/\W/, '') if options[:base_flex_package]
    @flex_root = options[:flex_root] if options[:flex_root]
    @use_gae = options[:gae]
    @use_air = options[:air_config]
    @distributed = options[:distributed] unless @distributed
    if @use_air
      @application_tag = 'WindowedApplication'
    else
      @application_tag = 'Application'
    end

    @component_names = []
  end

  def manifest
    record do |m|
      m.directory ''
      
      %w(script lib db config bin-debug).each { |dir| m.directory dir }
      
      if options[:gae]
        m.file 'index.yaml', 'index.yaml' unless File.exist?('index.yaml')
        m.template 'app.yaml.erb', 'app.yaml' unless File.exist?('app.yaml')
        m.directory 'app/controllers'
        m.file 'empty.txt', 'app/__init__.py'
        m.file 'empty.txt', 'app/controllers/__init__.py'
        m.directory 'app/models'
        m.file 'empty.txt', 'app/models/__init__.py'
      end

      m.template 'restfulx.yml', 'config/restfulx.yml'
      m.file 'default_tasks.rake', 'Rakefile' unless File.exist?('Rakefile')      
      m.file 'flex.properties', '.flexProperties'
      m.file 'generate.rb', 'script/generate', { :chmod => 0755 }
      if @use_air
        m.template 'actionscriptair.properties', '.actionScriptProperties'
        m.template 'projectair.properties', '.project'
      else
        m.template 'actionscript.properties', '.actionScriptProperties'
        m.template 'project.properties', '.project'
        
        m.directory 'html-template/history'      
        %w(index.template.html AC_OETags.js playerProductInstall.swf).each do |file|
          m.file "html-template/#{file}", "html-template/#{file}"
        end
        
        %w(history.css history.js historyFrame.html).each do |file|
          m.file "html-template/history/#{file}", "html-template/history/#{file}"
        end
        
        m.directory 'public/javascripts'
        m.file 'swfobject.js', 'public/javascripts/swfobject.js'
        m.file 'expressInstall.swf', 'public/expressInstall.swf'
        m.template 'index.html.erb', 'public/index.html'
      end
      
      %w(views controllers commands models events helpers).each do |dir|
        m.directory "#{flex_root}/#{base_folder}/#{dir}"
      end
      
      m.directory "#{flex_root}/#{base_folder}/views/generated"

      m.template 'project-textmate.erb', "#{project_name}.tmproj"
      m.template 'mainapp.mxml', File.join("#{flex_root}", "#{flex_project_name}.mxml")
      m.template 'mainapp-config.xml', File.join("#{flex_root}", "#{flex_project_name}-config.xml")
      m.template 'mainair-app.xml', File.join("#{flex_root}", "#{flex_project_name}-app.xml") if @use_air      
    end
  end

  protected
  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("-a", "--air", "Configure AIR project instead of Flex. Flex is default.", 
      "Default: false") { |v| options[:air_config] = v }
    opt.on("--gae", "Generate Google App Engine Python classes in addition to RestfulX Flex resources.", 
      "Default: false") { |v| options[:gae] = v }
    opt.on("--flex-root [FOLDER]", "Root folder for generated flex code.", 
      "Default: app/flex") { |v| options[:flex_root] = v }
    opt.on("--base-flex-package [PACKAGE]", "Base package for your application.", 
      "Default: #{flex_project_name}") { |v| options[:base_flex_package] = v }
    opt.on("--distributed", "Creates migrations, controllers and models that use UUIDs and are distribution ready", 
      "Default: false") { |v| options[:distributed] = v }
  end
end