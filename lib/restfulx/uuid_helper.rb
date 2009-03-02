require 'uuidtools'

module RestfulX
  module UUIDHelper
    def self.included(base)
      base.class_eval do 
        before_create :generate_uuid
      end
    end
  
    def generate_uuid
      self.id = UUID.random_create.to_s.gsub("-", "") unless self.id
    end
  end
end