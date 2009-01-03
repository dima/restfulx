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

depend_on 'rubigen', '1.4.0'
depend_on 'activesupport', '2.0.0'

task :default => 'spec:run'

PROJ.name = 'ruboss4ruby'
PROJ.summary = 'Ruboss Framework Code Generation Engine / Rails 2.1+ Integration Support'
PROJ.authors = 'Dima Berastau'
PROJ.email = 'dima@ruboss.com'
PROJ.url = 'http://github.com/dima/ruboss4ruby/wikis'
PROJ.version = Ruboss4Ruby::VERSION

PROJ.executables = ['bin/ruboss-gen']

#PROJ.rdoc.opts << '-Tjamis'
PROJ.rdoc.exclude << %w(.txt)
PROJ.rdoc.main = 'README.rdoc'
PROJ.rdoc.dir = 'doc/api'

PROJ.readme_file = 'README.rdoc'
PROJ.rubyforge.name = 'ruboss4ruby'

PROJ.exclude << %w(.DS_Store .gitignore .log, .sqlite3)

PROJ.spec.opts << '--color'
PROJ.test.opts << '-W1'

# EOF
