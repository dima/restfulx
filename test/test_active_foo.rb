require 'test/unit'
require 'rubygems'
require File.dirname(__FILE__) + '/test_helper.rb'

class ActiveFooTest < Test::Unit::TestCase

  def test_to_fxml_with_args_on_empty_array_should_not_blow_up
    a = ClassyEmptyArray.new(Object)
    assert_nothing_raised {a.to_fxml}
    assert_nothing_raised {a.to_fxml(:include => :test)}
  end
  
  def test_to_fxml_on_empty_classy_array_gives_class
    a = ClassyEmptyArray.new(Object)
    assert_match 'Object', a.to_fxml
  end

end
