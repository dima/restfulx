require File.join(File.dirname(__FILE__), 'test_helper')
require 'action_controller/performance_test'

ActionController::Base.perform_caching = true
ActiveSupport::Dependencies.mechanism = :require