class Task < ActiveRecord::Base
  belongs_to :project
  belongs_to :location
  belongs_to :user
    
  def is_active
    case
    when start_time && end_time 
      (start_time .. end_time) === Time.now
    when start_time && end_time.nil?
      start_time <= Time.now
    when start_time.nil && end_time
      end_time >= Time.now
    else
      true
    end
  end
end
