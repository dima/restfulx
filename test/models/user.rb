class User < ActiveRecord::Base
  has_one :note
  has_many :tasks
  has_many :projects
  has_many :locations
  
  default_fxml_methods :full_name, :has_nothing_to_do
  default_fxml_includes :tasks, :projects
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def has_nothing_to_do
    tasks.all? {|task| task.completed}
  end
  
  def email_host
    email.split('@').last
  end
end
