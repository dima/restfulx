$:.unshift(File.dirname(__FILE__))

require 'helpers/unit_test_helper'
require 'models/location'
require 'models/note'
require 'models/project'
require 'models/task'
require 'models/user'
require 'models/simple_property'

class ToAMFTest < ActiveRecord::TestCase
  fixtures :locations, :notes, :projects, :tasks, :users, :simple_properties
  
  def test_to_amf_sanity
    assert_nothing_raised {users(:ludwig).to_amf}
  end
end