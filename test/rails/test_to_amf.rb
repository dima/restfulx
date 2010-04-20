$:.unshift(File.dirname(__FILE__))

require 'helpers/unit_test_helper'

class ToAMFTest < ActiveRecord::TestCase
  fixtures :users
  
  def test_to_amf_sanity
    assert_nothing_raised {users(:user_1).to_amf}
  end
end