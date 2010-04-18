$:.unshift(File.dirname(__FILE__) + '/../..')
$:.unshift(File.dirname(__FILE__) + '/../../lib')
schema_file = File.join(File.dirname(__FILE__), '..', 'schema.rb')
ENV["RAILS_ENV"] = "test"

require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), '..', 'controllers', 'application_controller')
require File.join(File.dirname(__FILE__), '..', 'controllers', 'notes_controller')

config = YAML::load(IO.read(File.join(File.dirname(__FILE__), '..', 'database.yml')))['test']
puts "config:\n#{config.inspect}"
ActiveRecord::Base.configurations = config
ActiveRecord::Base.establish_connection(config)

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/../models.log")
ActionController::Base.logger = Logger.new(File.dirname(__FILE__) + "/../controllers.log")
ApplicationController.append_view_path File.join(File.dirname(__FILE__), '..', 'views')

load(schema_file) if File.exist?(schema_file)

ActiveSupport::TestCase.fixture_path = File.join(File.dirname(__FILE__), '..', 'fixtures')
$:.unshift(ActiveSupport::TestCase.fixture_path)
