require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "restfulx"
    gem.summary = "RestfulX Framework Code Generation Engine / Rails 2.1+ Integration Support"
    gem.description = "RestfulX: The RESTful Way to develop Adobe Flex and AIR applications"
    gem.email = "dima.berastau@gmail.com"
    gem.homepage = "http://restfulx.org"
    gem.rubyforge_project = "restfulx"
    gem.authors = ["Dima Berastau"]
    gem.files =  FileList["[A-Z]*", "{bin,app_generators,rails_generators,rxgen_generators,lib,test,spec,tasks}/**/*"]
    gem.files.exclude 'test/**/*.log', 'test/**/*.sqlite3'
    gem.test_files.exclude 'test/**/*.log', 'test/**/*.sqlite3'
    gem.add_dependency('rubigen', '>= 1.5.2')
    gem.add_dependency('activesupport', '>=2.0.0')
  end
  
  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = "rdoc"
  end
rescue LoadError
  puts "jeweler not available. Install it with: sudo gem install jeweler"
end

require 'rake/extensiontask'
Rake::ExtensionTask.new do |ext|
  ext.name            = 'serializer'
  ext.gem_spec        = Rake.application.jeweler_tasks.gemspec
  # ext.cross_compile   = true
  # ext.cross_platform  = %w[i386-mswin32 i386-mingw32]
  ext.ext_dir         = 'ext/restfulx/ext/amf/serializer'
  ext.lib_dir         = 'lib/restfulx/amf/ext'
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  config = YAML.load(File.read('VERSION.yml'))
  rdoc.rdoc_dir = 'doc/api'
  rdoc.title = "RestfulX #{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  rdoc.options << '--line-numbers' << '--inline-source' #<< '-Tjamis'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'rake/contrib/sshpublisher'
  namespace :rubyforge do
    namespace :release do
      desc "Publish RDoc to RubyForge."
      task :docs => [:rdoc] do
        config = YAML.load(
            File.read(File.expand_path('~/.rubyforge/user-config.yml'))
        )

        host = "#{config['username']}@rubyforge.org"
        remote_dir = "/var/www/gforge-projects/restfulx/"
        local_dir = 'doc/api'

        Rake::SshDirPublisher.new(host, remote_dir, local_dir).upload
      end
    end
  end
rescue LoadError
  puts "Rake SshDirPublisher is unavailable or your rubyforge environment is not configured."
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/**/test_*.rb'
  t.verbose = false
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |t|
    t.libs << 'test'
    t.test_files = FileList['test/**/test_*.rb']
    t.verbose = true
  end
rescue LoadError
  puts "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
end

begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features)
rescue LoadError
  puts "Cucumber is not available. In order to run features, you must: sudo gem install cucumber"
end

task :default => :test
