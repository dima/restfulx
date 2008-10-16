Merb::Generators::ResourceControllerGenerator.template :ruboss_resource_controller, :orm => :activerecord do |t|
  t.source = File.dirname(__FILE__) / "templates/ruboss_resource_controller/controller.rb.erb"
  t.destination = "app/controllers" / base_path / "#{file_name}.rb"
end