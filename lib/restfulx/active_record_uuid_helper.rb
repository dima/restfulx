# Patches ActiveRecord models to use UUID based IDs instead of the default numeric ones
require 'uuidtools'

# Extends ActiveRecord models with UUID based IDs
module RestfulX::UUIDHelper
  def self.included(base)
    base.class_eval do 
      before_create :generate_uuid
    end
  end

  def generate_uuid
    self.id = UUIDTools::UUID.random_create.to_s.gsub("-", "") unless self.id
  end
end