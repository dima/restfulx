require 'rubygems'
require 'test/unit'
RAILS_ROOT = File.dirname(__FILE__) unless defined? RAILS_ROOT
require File.join(File.dirname(__FILE__), 'helpers', 'test_helper')
require File.join(File.dirname(__FILE__), 'helpers', 'unit_test_helper')

class ActiveFooTest < Test::Unit::TestCase
  fixtures :all
  
  def setup
    @shakespeare = users(:shakespeare)
  end
  
  def test_task_fxml_includes_default_method
    set_response_to tasks(:haydn).to_fxml
    assert_xml_select 'task is_active'
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
    set_response_to projects(:music).to_fxml
    assert_xml_select 'project tasks task'
  end
  
  def test_projects_with_user_included_as_symbol
    set_response_to projects(:music).to_fxml(:include => :user)
    assert_xml_select 'project user'
  end
  
  def test_includes_as_hash_returns_hashes
    assert_equal Hash.new, User.includes_as_hash
    assert_equal ({:one => 1, :two => 2}), User.includes_as_hash({:one => 1, :two => 2})
    assert_equal ({:test => {}}), User.includes_as_hash(:test)
    assert_equal ({:test1 => {}, :test2 => {}}), User.includes_as_hash([:test1, :test2])
  end
  
  def test_validates_length_of_validates_length
    assert_nothing_raised do
      @shakespeare.login = 'william_shakespeare'
      @shakespeare.save
      assert !@shakespeare.errors.empty?
    end
    @shakespeare.login = 'william'
    @shakespeare.save
    assert @shakespeare.errors.empty?
  end
  
  def test_you_can_do_to_fxml_with_validates_length
    assert_nothing_raised do
      @shakespeare.to_fxml
    end
  end
  
  def test_array_of_users_includes_default_fxml_includes
    set_response_to User.find(:all).to_fxml
    assert_xml_select 'users user tasks task'
  end
  
  def test_to_fxml_should_take_a_block
    set_response_to users(:ludwig).to_fxml {|xml| xml.test 42}
    assert_xml_select 'test', '42'
  end

end
