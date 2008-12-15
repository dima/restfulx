# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

begin
  require 'bones'
  Bones.setup
rescue LoadError
  load 'tasks/setup.rb'
end

ensure_in_path 'lib'
require 'ruboss4ruby'

task :default => 'spec:run'

PROJ.name = 'ruboss4ruby'
PROJ.summary = 'Ruboss Framework Rails 2.1+ and Merb 1.0 Integration Support (RubyGem)'
PROJ.authors = 'Dima Berastau'
PROJ.email = 'dima@ruboss.com'
PROJ.url = 'http://github.com/dima/ruboss4ruby/wikis'
PROJ.version = Ruboss4Ruby::VERSION
PROJ.readme_file = 'README.rdoc'
PROJ.rubyforge.name = 'ruboss4ruby'

PROJ.spec.opts << '--color'

# EOF
