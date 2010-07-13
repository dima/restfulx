# Rake tasks for building RestfulX-based Flex and AIR applications
$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'rake'
require 'rexml/document'
require 'activesupport'
require 'configuration'

include RestfulX::Configuration

namespace :rx do
  # Compile the given Flex/AIR application
  # The following options are supported:
  #     :executable => 'mxmlc'
  #     :application => nil
  #     :destination => 'public/bin'
  #     :opts => nil
  #     :flex_root => 'app/flex'
  def compile_application(params = {})
    project_name, flex_project_name, command_controller_name, base_package, base_folder, 
      flex_root = extract_names()
    
    executable = params[:executable] || 'mxmlc'
    application = params[:application] || get_main_application
    destination = params[:destination] || 'public/bin'
    opts = params[:opts] || ''
    flex_root = params[:flex_root] || flex_root
    
    compiler = get_executable(executable)
    
    application = get_main_application unless application
    project_path = File.join(APP_ROOT, flex_root, application)
    target_project_path = project_path.sub(/.mxml$/, '.swf')
    target_project_air_descriptor = project_path.sub(/.mxml$/, '-app.xml')
      
    libs = Dir.glob(File.join(APP_ROOT, 'lib', '*.swc')).map {|lib| lib.gsub(' ', '\ ')}
      
    additional_compiler_args = 
      get_app_properties().elements["actionScriptProperties"].elements["compiler"].attributes["additionalCompilerArguments"]
    additional_compiler_args.gsub!("../locale/", "#{APP_ROOT}/app/locale/")
    
    cmd = "#{executable} #{opts} -library-path+=#{libs.join(',')} " << additional_compiler_args << " #{project_path.gsub(' ', '\ ')}"
    puts "Compiling #{project_path}"
    if system(cmd)
      FileUtils.makedirs File.join(APP_ROOT, destination)
      puts "Moving #{target_project_path} to " + File.join(APP_ROOT, destination)
      FileUtils.mv target_project_path, File.join(APP_ROOT, destination), :force => true
      if File.exist?(target_project_air_descriptor)
        descriptor = File.read(target_project_air_descriptor)
        descriptor_name = target_project_air_descriptor.split("/").last
        app_swf = target_project_path.split("/").last
        descriptor.gsub!("[This value will be overwritten by Flex Builder in the output app.xml]", 
          app_swf)

        File.open("#{APP_ROOT}/#{destination}/#{descriptor_name}", "w") do |file|
          file.print descriptor
        end
        puts "Created #{APP_ROOT}/#{destination}/#{descriptor_name} descriptor."
      end
      puts 'Done!'
    else
      puts "The application was not compiled. Check console for errors. " <<
        "It is possible that '(a)mxmlc' executable was not found or there are compilation errors."
    end
  end
  
  def run_air_application(params = {})
    application = params[:application] || get_main_application
    descriptor = params[:descriptor] || application.sub(/.mxml$/, '-app.xml')
    destination = params[:destination] || 'bin-debug'
    
    puts "Running AIR application with descriptor: #{descriptor}"
    if !system("#{get_executable('adl')} #{destination}/#{descriptor}")
      puts "Could not run the application with descriptor: #{destination}/#{descriptor}. Check console for errors."
    end
  end
  
  # Find what the main application is based on .actionScriptProperties file
  def get_main_application
    get_app_properties().root.attributes['mainApplicationPath'].split("/").last
  end
  
  def get_app_properties
    REXML::Document.new(File.open(File.join(APP_ROOT, ".actionScriptProperties")))
  end
  
  # Get appropriate executable based on platform
  def get_executable(executable)
    if RUBY_PLATFORM =~ /mswin32/
      executable << '.exe'
    end
    executable
  end
  
  namespace :flex do
    desc "Build project swf file and move it into public/bin folder"
    task :build do
      compile_application()
    end
  end
  
  namespace :air do
    desc "Build project swf file as an AIR application and move it into bin-debug folder"
    task :build do
      compile_application(:destination => 'bin-debug', :opts => '+configname=air')
    end
    
    desc "Run the AIR application (if this project is configured as an AIR project)"
    task :run do
      run_air_application
    end
  end
end