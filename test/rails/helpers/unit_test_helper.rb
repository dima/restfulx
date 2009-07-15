RAILS_ROOT = File.join(File.dirname(__FILE__), '..') unless defined? RAILS_ROOT

$:.unshift(File.dirname(__FILE__) + '/../..')
$:.unshift(File.dirname(__FILE__) + '/../../lib')
schema_file = File.join(File.dirname(__FILE__), '..', 'schema.rb')

require 'rubygems'
require 'test/unit'

require 'active_support'
require 'active_support/test_case'
require 'active_record'
require 'active_record/fixtures'
require 'action_controller'
require 'action_controller/test_case'
require 'action_controller/test_process'
require 'action_controller/integration'
require 'sqlite3'

require File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'restfulx')

config = YAML::load(IO.read(File.join(File.dirname(__FILE__), '..', 'database.yml')))[ENV['DB'] || 'test']
ActiveRecord::Base.configurations = config
ActiveRecord::Base.establish_connection(config)

load(schema_file) if File.exist?(schema_file)

ActiveSupport::TestCase.fixture_path.fixture_path = File.join(File.dirname(__FILE__), '..', 'fixtures')
$:.unshift(ActiveSupport::TestCase.fixture_path.fixture_path)