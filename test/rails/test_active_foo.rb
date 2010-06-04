RAILS_ROOT = File.dirname(__FILE__) unless defined? RAILS_ROOT
require File.join(File.dirname(__FILE__), 'helpers', 'test_helper')
require File.join(File.dirname(__FILE__), 'helpers', 'unit_test_helper')

class ActiveFooTest < ActiveRecord::TestCase
  fixtures :users, :tasks
  
  def test_user_fxml
    set_response_to users(:user_1).to_fxml
    assert_xml_select 'user'
  end
  
  # def test_task_fxml_has_default_method
  #    set_response_to tasks(:task_one_1).to_fxml(:methods => :is_active)
  #    assert_xml_select 'task is_active'
  #  end
  #  
  #  def test_user_fxml_includes_tasks
  #    set_response_to users(:user_1).to_fxml(:include => :tasks)
  #    assert_xml_select 'user tasks task'
  #  end
  #  
  #  def test_user_fxml_has_nothing_to_do_method
  #    set_response_to users(:user_1).to_fxml(:methods => :has_nothing_to_do)
  #    assert_xml_select 'user has_nothing_to_do'    
  #  end
  #  
  #  def test_user_fxml_includes_default_method_from_task
  #    set_response_to users(:user_1).to_fxml(:methods => :is_active, :include => :tasks)
  #    assert_xml_select 'user tasks task is_active'
  #  end
end
