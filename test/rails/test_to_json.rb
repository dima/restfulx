$:.unshift(File.dirname(__FILE__))

require 'helpers/unit_test_helper'
require 'models/location'
require 'models/note'
require 'models/project'
require 'models/task'
require 'models/user'
require 'models/simple_property'

class ToJsonTest < ActiveRecord::TestCase
  fixtures :locations, :notes, :projects, :tasks, :users, :simple_properties
  
  def test_to_json_sanity
    assert_nothing_raised {users(:ludwig).to_json}
  end
  
  def test_to_json_methods
    #set_response_to users(:ludwig).to_json
    #puts users(:ludwig).to_json
    puts User.all.to_json
  end
end