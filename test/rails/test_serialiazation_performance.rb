$:.unshift(File.dirname(__FILE__))

require 'helpers/unit_test_helper'
require 'helpers/performance_test_helper'

class SerializationPerformanceTest < ActionController::PerformanceTest
  fixtures :users
  
  def test_all_to_fxml
    users.to_fxml
  end
  
  def test_one_to_fxml
    users(:user_1).to_fxml
  end
  
  def test_all_to_json
    users.to_json
  end
  
  def test_one_to_json
    users(:user_1).to_json
  end
  
  def test_all_to_amf
    users.to_amf
  end
  
  def test_one_to_amf
    users(:user_1).to_amf
  end
end