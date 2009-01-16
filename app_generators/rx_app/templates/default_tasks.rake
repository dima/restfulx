# this will use the latest version of restfulx gem
require 'restfulx/tasks'

TEST_APP_NAME = 'TestApp.mxml'

namespace :air do
  desc "Build and run the AIR application"
  task :run => ["rx:air:build", "rx:air:run"]
end

namespace :flex do
  desc "Test flex application"
  task :test => ["rx:test:build", "rx:test:run"]
  
  desc "Build flex application"
  task :build do
    libs = [] # you can add libraries that are not in lib folder here
    compile_app(get_executable('mxmlc'), 'bin-debug', "-library-path+=#{libs.join(',')}")  
  end
end

namespace :rx do 
  namespace :test do
    desc "Build flex test swf file"
    task :build do
      project_path = File.join(APP_ROOT, "app/flex", TEST_APP_NAME)
    
      libs = Dir.glob(File.join(APP_ROOT, 'lib', '*.swc'))
      #libs << 'foobar' # you can add libraries that not in lib folder here
    
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
