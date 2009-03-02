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
    compile_application(:destination => 'bin-debug', :opts => "-library-path+=#{libs.join(',')}")  
  end
end

namespace :rx do 
  namespace :test do
    desc "Build flex test swf file"
    task :build do
      libs = Dir.glob(File.join(APP_ROOT, 'lib', '*.swc'))
      #libs << 'foobar' # you can add libraries that not in lib folder here
      
      compile_application(:application => TEST_APP_NAME, :destination => 'bin-debug', 
        :opts => "+configname=air -library-path+=#{libs.join(',')}")
    end
    
    desc "Run flex test application"
    task :run do
      run_air_application(:application => TEST_APP_NAME)
    end
  end
end
