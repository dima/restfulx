RAILS_ROOT = File.join(File.dirname(__FILE__), '..') unless defined? RAILS_ROOT

require 'rubygems'
require 'test/unit'

gem 'activesupport', '= 2.3.2'
gem 'activerecord', '= 2.3.2'
gem 'actionpack', '= 2.3.2'
gem 'rails', '= 2.3.2'

require 'activesupport'
require 'active_support/core_ext'
require 'active_support/test_case'
require 'active_record'
require 'active_record/fixtures'
require 'action_controller'
require 'action_controller/test_case'
require 'action_controller/test_process'
require 'action_controller/integration'
require 'action_controller/assertions/selector_assertions'
require 'action_controller/assertions/response_assertions'
require 'sqlite3'

require File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'restfulx')
require File.join(File.dirname(__FILE__), '..',  'models', 'note')
require File.join(File.dirname(__FILE__), '..', 'models', 'user')
require File.join(File.dirname(__FILE__), '..', 'models', 'project')
require File.join(File.dirname(__FILE__), '..', 'models', 'location')
require File.join(File.dirname(__FILE__), '..', 'models', 'task')
require File.join(File.dirname(__FILE__), '..', 'models', 'simple_property')

class MockResponse
  attr_reader :body, :content_type

  def initialize(body, content_type = 'xml')
    @body = body
    @content_type = content_type
  end

end

class ActiveSupport::TestCase
  include ActiveRecord::TestFixtures
  include ActionController::TestProcess
  include ActionController::Assertions::SelectorAssertions
  include ActionController::Assertions::ResponseAssertions

  self.fixture_path = File.join(File.dirname(__FILE__), "../fixtures")

  self.use_transactional_fixtures = false
  self.use_instantiated_fixtures = false

  # load up fixtures
  # fixtures :all
end

class ActiveRecord::TestCase #:nodoc:
  # Add more helper methods to be used by all tests here...

  # Use this to test xml or fxml responses in unit tests.  For example,
  # set_response_to user.to_fxml
  # assert_xml_select 'user name', 'quentin'
  def set_response_to(response, content_type = 'xml')
    @response = MockResponse.new(response, content_type)
  end

  # Make xml functional testing work.
  # From http://weblog.jamisbuck.org/2007/1/4/assert_xml_select
  def xml_document
    @xml_document ||= HTML::Document.new(@response.body, false, true)
  end  

  def assert_xml_select(*args, &block)
    @html_document = xml_document
    assert_select(*args, &block)
  end
  
  def assert_invalid(record)
    assert !record.valid?
  end
end