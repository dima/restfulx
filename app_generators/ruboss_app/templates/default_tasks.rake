require 'rubygems'
require 'ruboss4ruby/tasks'

TEST_APP_NAME = 'TestApp.mxml'

namespace :air do
  desc "Build and run the AIR application"
  task :run => ["ruboss:air:build", "ruboss:air:run"]
end

namespace :flex do
  desc "Test flex application"
  task :test => ["ruboss:test:build", "ruboss:test:run"]
  
  desc "Build flex application"
  task :build do
    libs = [] # < '/Users/Dima/Projects/ruboss/ruboss_framework/framework/bin/ruboss.swc'
    compile_app(get_executable('mxmlc'), 'bin-debug', "-library-path+=#{libs.join(',')}")  
  end
end

namespace :ruboss do 
  namespace :test do
    desc "Build flex test swf file"
    task :build do
      project_path = File.join(APP_ROOT, "app/flex", TEST_APP_NAME)
    
      libs = Dir.glob(File.join(APP_ROOT, 'lib', '*.swc'))
      #libs << '/Users/Dima/Projects/ruboss/ruboss_framework/framework/bin/ruboss.swc'
    
      target_project_path = File.join(APP_ROOT, "bin-debug", TEST_APP_NAME.sub(/.mxml$/, '.swf'))
    
      cmd = "#{get_executable('mxmlc')} +configname=air -library-path+=#{libs.join(',')} " << 
        "-output #{target_project_path} -debug=true #{project_path}"

      if !system("#{cmd}")
        puts "failed to compile test application"
      end
    end
    
    desc "Run flex test application"
    task :run do
      project_path = File.join(APP_ROOT, "app/flex", TEST_APP_NAME)
      target_project_air_descriptor = project_path.sub(/.mxml$/, '-app.xml')
      
      if !system("#{get_executable('adl')} #{target_project_air_descriptor} #{APP_ROOT}")
        puts "failed to run test application"
      end 
    end
  end
end
