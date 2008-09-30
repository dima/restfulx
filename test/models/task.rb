class Task < ActiveRecord::Base
  belongs_to :project
  belongs_to :location
  belongs_to :user
  
  default_fxml_methods :is_active
  
  def is_active
    (start_time .. end_time) === Time.now
  end
end
