# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruboss4ruby}
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dima Berastau"]
  s.date = %q{2008-12-12}
  s.description = %q{FIX (describe your package)}
  s.email = ["dima@ruboss.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.rdoc", "gpl-3.0.txt", "rcl-1.0.txt", "test/rails/playing_around_in_a_console.txt"]
  s.files = ["Generators", "History.txt", "Manifest.txt", "README.rdoc", "gpl-3.0.txt", "lib/ruboss4ruby.rb", "lib/ruboss4ruby/active_foo.rb", "lib/ruboss4ruby/active_record_tasks.rb", "lib/ruboss4ruby/configuration.rb", "lib/ruboss4ruby/datamapper_foo.rb", "lib/ruboss4ruby/generated_attribute.rb", "lib/ruboss4ruby/rails/recipes.rb", "lib/ruboss4ruby/rails/ruboss_helper.rb", "lib/ruboss4ruby/rails/ruboss_test_helpers.rb", "lib/ruboss4ruby/tasks.rb", "merb_generators/ruboss_config.rb", "merb_generators/ruboss_controller.rb", "merb_generators/ruboss_flex_app.rb", "merb_generators/ruboss_resource.rb", "merb_generators/ruboss_resource_controller.rb", "merb_generators/ruboss_scaffold.rb", "merb_generators/templates/ruboss_config/actionscript.properties", "merb_generators/templates/ruboss_config/actionscriptair.properties", "merb_generators/templates/ruboss_config/expressInstall.swf", "merb_generators/templates/ruboss_config/flex.properties", "merb_generators/templates/ruboss_config/html-template/AC_OETags.js", "merb_generators/templates/ruboss_config/html-template/history/history.css", "merb_generators/templates/ruboss_config/html-template/history/history.js", "merb_generators/templates/ruboss_config/html-template/history/historyFrame.html", "merb_generators/templates/ruboss_config/html-template/index.template.html", "merb_generators/templates/ruboss_config/html-template/playerProductInstall.swf", "merb_generators/templates/ruboss_config/index.html.erb", "merb_generators/templates/ruboss_config/mainair-app.xml", "merb_generators/templates/ruboss_config/project.properties", "merb_generators/templates/ruboss_config/projectair.properties", "merb_generators/templates/ruboss_config/ruboss.yml", "merb_generators/templates/ruboss_config/swfobject.js", "merb_generators/templates/ruboss_controller/controller.as.erb", "merb_generators/templates/ruboss_flex_app/mainapp.mxml", "merb_generators/templates/ruboss_resource_controller/controller_ar.rb.erb", "merb_generators/templates/ruboss_resource_controller/controller_dm.rb.erb", "merb_generators/templates/ruboss_resource_controller/spec/controllers/%file_name%_spec.rb", "merb_generators/templates/ruboss_resource_controller/spec/requests/%file_name%_spec.rb", "merb_generators/templates/ruboss_resource_controller/test/controllers/%file_name%_test.rb", "rails_generators/ruboss_config/USAGE", "rails_generators/ruboss_config/ruboss_config_generator.rb", "rails_generators/ruboss_config/templates/actionscript.properties", "rails_generators/ruboss_config/templates/actionscriptair.properties", "rails_generators/ruboss_config/templates/expressInstall.swf", "rails_generators/ruboss_config/templates/flex.properties", "rails_generators/ruboss_config/templates/html-template/AC_OETags.js", "rails_generators/ruboss_config/templates/html-template/history/history.css", "rails_generators/ruboss_config/templates/html-template/history/history.js", "rails_generators/ruboss_config/templates/html-template/history/historyFrame.html", "rails_generators/ruboss_config/templates/html-template/index.template.html", "rails_generators/ruboss_config/templates/html-template/playerProductInstall.swf", "rails_generators/ruboss_config/templates/index.html.erb", "rails_generators/ruboss_config/templates/mainair-app.xml", "rails_generators/ruboss_config/templates/mainapp-config.xml", "rails_generators/ruboss_config/templates/mainapp.mxml", "rails_generators/ruboss_config/templates/project-textmate.erb", "rails_generators/ruboss_config/templates/project.properties", "rails_generators/ruboss_config/templates/projectair.properties", "rails_generators/ruboss_config/templates/ruboss.yml", "rails_generators/ruboss_config/templates/ruboss_tasks.rake", "rails_generators/ruboss_config/templates/swfobject.js", "rails_generators/ruboss_controller/USAGE", "rails_generators/ruboss_controller/ruboss_controller_generator.rb", "rails_generators/ruboss_controller/templates/controller.as.erb", "rails_generators/ruboss_scaffold/USAGE", "rails_generators/ruboss_scaffold/ruboss_scaffold_generator.rb", "rails_generators/ruboss_scaffold/templates/component.mxml.erb", "rails_generators/ruboss_scaffold/templates/controller.rb.erb", "rails_generators/ruboss_scaffold/templates/fixtures.yml.erb", "rails_generators/ruboss_scaffold/templates/migration.rb.erb", "rails_generators/ruboss_scaffold/templates/model.as.erb", "rails_generators/ruboss_scaffold/templates/model.rb.erb", "rails_generators/ruboss_yaml_scaffold/USAGE", "rails_generators/ruboss_yaml_scaffold/ruboss_yaml_scaffold_generator.rb", "rcl-1.0.txt", "ruboss4ruby.gemspec", "test/rails/controllers/application.rb", "test/rails/controllers/locations_controller.rb", "test/rails/controllers/notes_controller.rb", "test/rails/controllers/projects_controller.rb", "test/rails/controllers/tasks_controller.rb", "test/rails/controllers/users_controller.rb", "test/rails/database.yml", "test/rails/fixtures/locations.yml", "test/rails/fixtures/notes.yml", "test/rails/fixtures/projects.yml", "test/rails/fixtures/simple_properties.yml", "test/rails/fixtures/tasks.yml", "test/rails/fixtures/users.yml", "test/rails/helpers/controllers.log", "test/rails/helpers/functional_test_helper.rb", "test/rails/helpers/models.log", "test/rails/helpers/test_helper.rb", "test/rails/helpers/unit_test_helper.rb", "test/rails/model.yml", "test/rails/models/location.rb", "test/rails/models/note.rb", "test/rails/models/project.rb", "test/rails/models/simple_property.rb", "test/rails/models/task.rb", "test/rails/models/user.rb", "test/rails/playing_around_in_a_console.txt", "test/rails/schema.rb", "test/rails/test.sqlite3", "test/rails/test.swf", "test/rails/test_active_foo.rb", "test/rails/test_helper.rb", "test/rails/test_ruboss4ruby.rb", "test/rails/test_ruboss_rails_integration_functional.rb", "test/rails/to_fxml_test.rb", "test/rails/views/notes/empty_params_action.html.erb", "test/rails/views/notes/index.html.erb"]
  s.has_rdoc = true
  s.homepage = %q{FIX (url)}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ruboss4ruby}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{FIX (describe your package)}
  s.test_files = ["test/rails/helpers/test_helper.rb", "test/rails/test_active_foo.rb", "test/rails/test_helper.rb", "test/rails/test_ruboss4ruby.rb", "test/rails/test_ruboss_rails_integration_functional.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<newgem>, [">= 1.1.0"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<newgem>, [">= 1.1.0"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<newgem>, [">= 1.1.0"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
