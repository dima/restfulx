class Project < ActiveRecord::Base
  belongs_to :user
  has_many :tasks
  
  default_fxml_includes :tasks
end
