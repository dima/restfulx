Merb::Generators::ResourceControllerGenerator.template :ruboss_resource_controller do
  source(File.dirname(__FILE__), "templates/ruboss_resource_controller/controller.rb.erb")
  destination("app/controllers", base_path, "#{file_name}.rb")
end