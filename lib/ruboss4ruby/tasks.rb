require 'rake'
require 'ftools'
require 'rexml/document'
require File.join(File.dirname(__FILE__), 'configuration')

APP_ROOT = Ruboss4Ruby::Configuration::APP_ROOT

namespace :ruboss do
  def compile_app(executable, destination, opts = '')
    app_properties = REXML::Document.new(File.open(File.join(APP_ROOT, ".actionScriptProperties")))
    app_properties.elements.each("*/applications/application") do |elm|
      app_path = elm.attributes['path']
      project_path = File.join(APP_ROOT, "app/flex", app_path)
      target_project_path = project_path.sub(/.mxml$/, '.swf')
      target_project_air_descriptor = project_path.sub(/.mxml$/, '-app.xml')
      
      libs = Dir.glob(File.join(APP_ROOT, 'lib', '*.swc')).map {|lib| lib.gsub(' ', '\ ')}
      
      cmd = "#{executable} #{opts} -library-path+=#{libs.join(',')} " << 
        "-keep-as3-metadata+=Resource,HasOne,HasMany,BelongsTo,DateTime,Lazy,Ignored #{project_path.gsub(' ', '\ ')}"
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
  end
  
  def get_main_application
    app_properties = REXML::Document.new(File.open(File.join(APP_ROOT, ".actionScriptProperties")))
    app_properties.root.attributes['mainApplicationPath'].split("/").last
  end
  
  def get_executable(executable)
    if RUBY_PLATFORM =~ /mswin32/
      executable << '.exe'
    end
    executable
  end
  
  namespace :flex do
    desc "Build project swf file and move it into public/bin folder"
    task :build do
      compile_app(get_executable('mxmlc'), 'public/bin')
    end
  end
  
  namespace :air do
    desc "Build project swf file as an AIR application and move it into bin-debug folder"
    task :build do   
      compile_app(get_executable('mxmlc'), 'bin-debug', '+configname=air')
    end
    
    desc "Run the AIR application (if this project is configured as an AIR project)"
    task :run do
      target = get_main_application.gsub(/.mxml$/, '-app.xml')
      puts "Running AIR application with descriptor: #{target}"
      if !system("#{get_executable('adl')} bin-debug/#{target}")
        puts "Could not run the application with descriptor: #{target}. Check console for errors."
      end
    end
  end
end