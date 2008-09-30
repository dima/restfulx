require 'test/unit'
require 'rubygems'

require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'helpers', 'functional_test_helper')
require File.join(File.dirname(__FILE__),  'models', 'note')
require File.join(File.dirname(__FILE__), 'models', 'user')
require File.join(File.dirname(__FILE__), 'models', 'project')
require File.join(File.dirname(__FILE__), 'models', 'location')
require File.join(File.dirname(__FILE__), 'models', 'task')


ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
end


class RubossRailsIntegrationFunctionalTest < Test::Unit::TestCase
  fixtures :all
  
  def setup    
    @controller = NotesController.new()
    @controller.request = @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new    
  end

  def test_render_with_an_empty_params_hash_should_not_blow_up
    get :empty_params_action
    assert_response :success
  end

end
