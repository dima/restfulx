# if the gem is not installed system wide, we'll just skip the tasks

require 'rubygems'
require 'ruboss4ruby/tasks'

# APP_NAME = 'KarmasoftTest.mxml'

# namespace :flex do
#   desc "Test the flex application"
#   task :test => ["ruboss:test:build", "ruboss:test:run"]
#   
#   desc "Build flex applications"
#   task :build do
#     extra_lib = '/Users/Dima/Projects/ruboss/ruboss_framework/framework/bin/ruboss.swc'
#     compile_app(get_executable('mxmlc'), 'public/bin', "-library-path+=#{extra_lib}")  
#   end
# end
# 
# namespace :ruboss do 
#   namespace :test do
#     desc "Build flex test swf file"
#     task :build do
#       project_path = File.join(APP_ROOT, "app/flex", APP_NAME)
#     
#       libs = Dir.glob(File.join(APP_ROOT, 'lib', '*.swc'))
#       libs << '/Users/Dima/Projects/ruboss/ruboss_framework/framework/bin/ruboss.swc'
#     
#       target_project_path = File.join(APP_ROOT, "public/bin", APP_NAME.sub(/.mxml$/, '.swf'))
#     
#       cmd = "#{get_executable('mxmlc')} +configname=air -library-path+=#{libs.join(',')} " << 
#         "-output #{target_project_path} -debug=true #{project_path}"
# 
#       if !system("#{cmd}")
#         puts "failed to compile test application"
#       end
#     end
#     
#     desc "Run flex test application"
#     task :run do
#       project_path = File.join(APP_ROOT, "app/flex", APP_NAME)
#       target_project_air_descriptor = project_path.sub(/.mxml$/, '-app.xml')
#       
#       if !system("#{get_executable('adl')} #{target_project_air_descriptor} #{APP_ROOT}")
#         puts "failed to run test application"
#       end 
#     end
#   end
# end
