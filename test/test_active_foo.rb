require 'test/unit'
require 'rubygems'
require File.dirname(__FILE__) + '/test_helper.rb'
require File.join(File.dirname(__FILE__), 'helpers', 'unit_test_helper')


class ActiveFooTest < Test::Unit::TestCase
  fixtures :all

  def test_to_fxml_with_args_on_empty_array_should_not_blow_up
    a = ClassyEmptyArray.new(Object)
    assert_nothing_raised {a.to_fxml}
    assert_nothing_raised {a.to_fxml(:include => :test)}
  end
  
  def test_to_fxml_on_empty_classy_array_gives_class
    a = ClassyEmptyArray.new(Object)
    assert_match 'Object', a.to_fxml
  end
  
  def test_user_fxml_includes_tasks
    set_response_to users(:ludwig).to_fxml
    assert_xml_select 'user tasks task'
  end
  
  def test_user_fxml_includes_has_nothing_to_do_method
    set_response_to users(:ludwig).to_fxml
    assert_xml_select 'user has_nothing_to_do'    
  end
  
  def test_user_fxml_includes_default_method_from_task
    set_response_to users(:ludwig).to_fxml
    assert_xml_select 'user tasks task is_active'
  end
  
  def test_projects_fxml_includes_tasks
    
  end
  
  def test_projects_with_user_included_as_symbol
    
  end

end
