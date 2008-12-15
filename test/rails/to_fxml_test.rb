$:.unshift(File.dirname(__FILE__))

require 'helpers/unit_test_helper'
require 'models/location'
require 'models/note'
require 'models/project'
require 'models/task'
require 'models/user'
require 'models/simple_property'


class ToFxmlTest < Test::Unit::TestCase
  fixtures :locations, :notes, :projects, :tasks, :users, :simple_properties
  
  # def test_to_fxml_sanity
  #   assert_nothing_raised {users(:ludwig).to_fxml}
  # end
  # 
  # def test_to_fxml_doesnt_dasherize
  #   set_response_to users(:ludwig).to_fxml
  #   assert_xml_select 'user first_name', 'Ludwig'    
  # end
  # 
  # def test_default_xml_methods_on_user_are_included_in_fxml
  #   set_response_to users(:ludwig).to_fxml
  #   assert_xml_select 'user full_name', 'Ludwig van Beethoven'
  #   assert_xml_select 'user has_nothing_to_do'
  # end
  # 
  # def test_default_xml_methods_on_user_are_included_in_fxml_if_you_call_it_twice
  #   set_response_to users(:ludwig).to_fxml
  #   set_response_to users(:ludwig).to_fxml
  #   assert_xml_select 'user full_name', 'Ludwig van Beethoven'
  #   assert_xml_select 'user has_nothing_to_do'
  # end
  # 
  # 
  # def test_default_xml_methods_on_task_are_included_in_fxml
  #   set_response_to tasks(:learn_piano).to_fxml
  #   assert_xml_select 'task is_active'
  # end
  # 
  # def test_default_xml_methods_exists
  #   assert User.respond_to?(:default_xml_methods_array)
  #   assert_equal [:full_name, :has_nothing_to_do], User.default_xml_methods_array
  # end
  # 
  # def test_default_xml_methods_on_dependencies
  #   t = users(:ludwig).tasks.first
  #   assert t.class.respond_to?(:default_xml_methods_array)
  #   assert_equal [:is_active], t.class.default_xml_methods_array
  # end
  # 
  # def test_default_xml_methods_are_included_in_includes
  #   set_response_to users(:ludwig).to_fxml(:include => :tasks)
  #   assert_xml_select 'tasks task is_active'
  # end
  # 
  # def test_model_without_default_xml_methods_still_works
  #   assert_nothing_raised{ locations(:vienna).to_fxml }
  # end
  # 
  # def test_user_with_non_default_methods_in_to_xml
  #   set_response_to users(:ludwig).to_fxml(:methods => :email_host)
  #   assert_xml_select 'user email_host', 'vienna.de'
  #   assert_xml_select 'user full_name'
  # end
  # 
  # def test_model_with_default_xml_includes
  #   set_response_to users(:ludwig).to_fxml
  #   assert_xml_select 'user tasks task'
  # end
  # 
  # def test_simple_properies
  #   puts simple_properties
  # end
  
  # Test type=.... stuff for has_many, booleans, integers, dates, date-times
  
  # Test empty arrays
  
  # Test options[:except]
  
end