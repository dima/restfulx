$:.unshift(File.dirname(__FILE__))

require 'helpers/unit_test_helper'

class ToJsonTest < ActiveRecord::TestCase
  fixtures :users
  
  def test_to_json_sanity
    assert_nothing_raised {users(:user_1).to_json}
  end
end