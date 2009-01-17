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
require 'restfulx'

depend_on 'rubigen', '1.4.0'
depend_on 'activesupport', '2.0.0'

task :default => 'spec:run'

PROJ.name = 'restfulx'
PROJ.summary = 'RestfulX Framework Code Generation Engine / Rails 2.1+ Integration Support'
PROJ.authors = 'Dima Berastau'
PROJ.email = 'dima.berastau@gmail.com'
PROJ.url = 'http://wiki.github.com/dima/restfulx'
PROJ.version = RestfulX::VERSION

PROJ.executables = ['bin/rx-gen']

#PROJ.rdoc.opts << '-Tjamis'
PROJ.rdoc.exclude << %w(.txt)
PROJ.rdoc.main = 'README.rdoc'
PROJ.rdoc.dir = 'doc/api'

PROJ.readme_file = 'README.rdoc'
PROJ.rubyforge.name = 'restfulx'

PROJ.exclude << %w(.DS_Store .gitignore .log, .sqlite3)

PROJ.spec.opts << '--color'
PROJ.test.opts << '-W1'

# EOF
