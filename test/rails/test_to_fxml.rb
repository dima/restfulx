$:.unshift(File.dirname(__FILE__))

require 'helpers/unit_test_helper'

class ToFxmlTest < ActiveRecord::TestCase
  fixtures :users
  
  def test_to_fxml_sanity
    assert_nothing_raised {users(:user_1).to_fxml}
  end
  
  def test_to_fxml_doesnt_dasherize
    set_response_to users(:user_1).to_fxml
    assert_xml_select 'user first_name', 'Foo1'    
  end
  
  def test_default_xml_methods_on_user_are_included_in_fxml
    set_response_to users(:user_1).to_fxml(:methods => [:has_nothing_to_do, :full_name])
    assert_xml_select 'user full_name', 'Foo1 Bar1'
    assert_xml_select 'user has_nothing_to_do'
  end
  
  def test_default_xml_methods_on_user_are_included_in_fxml_if_you_call_it_twice
    set_response_to users(:user_1).to_fxml(:methods => [:has_nothing_to_do, :full_name])
    set_response_to users(:user_1).to_fxml(:methods => [:has_nothing_to_do, :full_name])
    assert_xml_select 'user full_name', 'Foo1 Bar1'
    assert_xml_select 'user has_nothing_to_do'
  end

  # need to fix this
  # def test_to_fxml_serializes_validation_errors
  #   vince = users(:vincent)
  #   assert_invalid vince
  #   assert_not_nil vince.errors
  #   set_response_to vince.errors.to_fxml
  #   assert_xml_select 'errors error'
  # end
end