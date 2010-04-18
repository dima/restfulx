$:.unshift(File.dirname(__FILE__))

require 'helpers/unit_test_helper'
require 'helpers/performance_test_helper'
require 'models/location'
require 'models/note'
require 'models/project'
require 'models/task'
require 'models/user'
require 'models/simple_property'

class SerializationPerformanceTest < ActionController::PerformanceTest
  fixtures :locations, :notes, :projects, :tasks, :users, :simple_properties
  
  def test_to_fxml
    users(:ludwig).to_fxml
  end
  
  def test_to_json
    users(:ludwig).to_json
  end
  
  def test_to_amf
    users(:ludwig).to_amf
  end
end