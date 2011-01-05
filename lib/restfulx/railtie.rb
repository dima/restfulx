require 'restfulx'
require 'rails'

module RestfulX
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.join(File.dirname(__FILE__), "..", "..", "tasks", "restfulx.rake")
    end
  end
end