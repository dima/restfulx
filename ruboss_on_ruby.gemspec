Gem::Specification.new do |s|
  s.name = %q{ruboss_on_ruby}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dima Berastau"]
  s.date = %q{2008-07-11}
  s.description = %q{Ruboss Framework Integration Support for Rails 2.+ and Merb 0.9.3+}
  s.email = ["dima@ruboss.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt", "gpl-3.0.txt", "rcl-1.0.txt", "website/index.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "config/hoe.rb", "config/requirements.rb", "gpl-3.0.txt", "lib/ruboss_on_ruby.rb", "lib/ruboss_on_ruby/active_foo.rb", "lib/ruboss_on_ruby/active_record_tasks.rb", "lib/ruboss_on_ruby/configuration.rb", "lib/ruboss_on_ruby/tasks.rb", "lib/ruboss_on_ruby/version.rb", "merb_generators/ruboss_config/USAGE", "merb_generators/ruboss_config/ruboss_config_generator.rb", "merb_generators/ruboss_controller/USAGE", "merb_generators/ruboss_controller/ruboss_controller_generator.rb", "merb_generators/ruboss_scaffold/USAGE", "merb_generators/ruboss_scaffold/ruboss_scaffold_generator.rb", "merb_generators/ruboss_yaml_scaffold/USAGE", "merb_generators/ruboss_yaml_scaffold/ruboss_yaml_scaffold_generator.rb", "rails_generators/ruboss_config/USAGE", "rails_generators/ruboss_config/ruboss_config_generator.rb", "rails_generators/ruboss_config/templates/actionscript.properties", "rails_generators/ruboss_config/templates/actionscriptair.properties", "rails_generators/ruboss_config/templates/expressInstall.swf", "rails_generators/ruboss_config/templates/flex.properties", "rails_generators/ruboss_config/templates/html-template/AC_OETags.js", "rails_generators/ruboss_config/templates/html-template/history/history.css", "rails_generators/ruboss_config/templates/html-template/history/history.js", "rails_generators/ruboss_config/templates/html-template/history/historyFrame.html", "rails_generators/ruboss_config/templates/html-template/index.template.html", "rails_generators/ruboss_config/templates/html-template/playerProductInstall.swf", "rails_generators/ruboss_config/templates/index.html.erb", "rails_generators/ruboss_config/templates/mainair-app.xml", "rails_generators/ruboss_config/templates/mainapp.mxml", "rails_generators/ruboss_config/templates/project.properties", "rails_generators/ruboss_config/templates/projectair.properties", "rails_generators/ruboss_config/templates/ruboss_tasks.rake", "rails_generators/ruboss_config/templates/swfobject.js", "rails_generators/ruboss_controller/USAGE", "rails_generators/ruboss_controller/ruboss_controller_generator.rb", "rails_generators/ruboss_controller/templates/controller.as.erb", "rails_generators/ruboss_scaffold/USAGE", "rails_generators/ruboss_scaffold/ruboss_scaffold_generator.rb", "rails_generators/ruboss_scaffold/templates/component.mxml.erb", "rails_generators/ruboss_scaffold/templates/controller.rb.erb", "rails_generators/ruboss_scaffold/templates/fixtures.yml.erb", "rails_generators/ruboss_scaffold/templates/migration.rb.erb", "rails_generators/ruboss_scaffold/templates/model.as.erb", "rails_generators/ruboss_scaffold/templates/model.rb.erb", "rails_generators/ruboss_yaml_scaffold/USAGE", "rails_generators/ruboss_yaml_scaffold/ruboss_yaml_scaffold_generator.rb", "rcl-1.0.txt", "script/console", "script/destroy", "script/generate", "script/txt2html", "setup.rb", "tasks/deployment.rake", "tasks/environment.rake", "tasks/website.rake", "test/test_generator_helper.rb", "test/test_helper.rb", "test/test_ruboss_config_generator.rb", "test/test_ruboss_controller_generator.rb", "test/test_ruboss_on_ruby.rb", "test/test_ruboss_scaffold_generator.rb", "test/test_ruboss_yaml_scaffold_generator.rb", "website/index.html", "website/index.txt", "website/javascripts/rounded_corners_lite.inc.js", "website/stylesheets/screen.css", "website/template.html.erb"]
  s.has_rdoc = true
  s.homepage = %q{http://ruboss_on_ruby.rubyforge.org}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ruboss_on_ruby}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Ruboss Framework Integration Support for Rails 2.+ and Merb 0.9.3+}
  s.test_files = ["test/test_generator_helper.rb", "test/test_helper.rb", "test/test_ruboss_config_generator.rb", "test/test_ruboss_controller_generator.rb", "test/test_ruboss_on_ruby.rb", "test/test_ruboss_scaffold_generator.rb", "test/test_ruboss_yaml_scaffold_generator.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
    else
    end
  else
  end
end
