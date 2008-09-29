class User < ActiveRecord::Base
  has_one :note
  has_many :tasks
  has_many :projects
  has_many :locations
  
  default_xml_methods :full_name, :has_nothing_to_do
  default_xml_includes :tasks
  
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
