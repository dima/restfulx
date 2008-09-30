require 'test/unit'
require 'rubygems'
require 'action_controller'
require 'active_support'
require 'active_support/test_case'
require 'active_record'
require File.join(File.dirname(__FILE__), 'test_helper')
# require File.join(File.dirname(__FILE__), 'helpers', 'functional_test_helper')

ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
end


class RubossRailsIntegrationTest < Test::Unit::TestCase
  
  def test_to_fxml_with_args_on_empty_array_should_not_blow_up
    a = ClassyEmptyArray.new(Object)
    assert_nothing_raised {a.to_fxml}
    assert_nothing_raised {a.to_fxml(:include => :test)}
  end


end
