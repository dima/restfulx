require 'ruboss4ruby/configuration'
require 'ruboss4ruby/generated_attribute'

#NOTE: this is currently (merb 0.9.9 broken and needs to be rethought anyway. This line of thinking was based
# on the kind of code generation you could do with rails, it's a different code generation paradigm with Merb anyway)
module Merb::Generators
  class RubossScaffoldGenerator < NamespacedGenerator
    include Ruboss::Configuration
    
    option :flex_only, :as => :boolean, :default => false, :desc => 'Scaffold Flex code only.'
    option :skip_migration, :as => :boolean, :default => false, :desc => 'Skip migration for this model.'

    first_argument :name, :required => true, :desc => "model name"
    second_argument :properties, :as => :hash, :required => true, :default => {}, :desc => "space separated model properties in form of name:type. Example: state:string"
    
    def initialize(*args)
      @project_name, @flex_project_name, @command_controller_name, @base_package, @base_folder = extract_names
      super
    end
    
    def table_name
      file_name.pluralize
    end
    
    alias_method :resource_controller_name, :table_name
    
    def model_name
      name
    end
    
    def controller_name
      name.pluralize
    end

    def project_name
      @project_name
    end

    def flex_project_name
      @flex_project_name
    end

    def base_folder
      @base_folder
    end
    
    def base_package
      @base_package
    end
    
    def command_controller_name
      @command_controller_name
    end
    
    def belongs_tos
      @belongs_tos
    end
    
    def has_manies
      @has_manies
    end
    
    def has_ones
      @has_ones
    end
    
    def attributes
      @belongs_tos = []
      @has_ones = []
      @has_manies = []
      # Figure out has_one, has_many and belongs_to based on args
      self.properties.each do |key,value|
        puts key + value
        key = key.to_sym
        if key == :has_one
          # arg = "has_one:arg1,arg2", so all the has_one are together
          @has_ones = value.split(',')
        elsif key == :has_many
          # arg = "has_many:arg1,arg2", so all the has_many are together 
          @has_manies = value.split(",")
        elsif key == :belongs_to # belongs_to:arg1,arg2
          @belongs_tos = value.split(',')
        end
      end
      
      puts "does this even run?"
      
      puts belongs_tos
      puts has_manies
      
      # Remove the has_one and has_many arguments since they are
      # not for consumption by the scaffold generator, and since
      # we have already used them to set the @belongs_tos, @has_ones and
      # @has_manies.
      self.properties.delete_if { |key, value| key =~ /^(has_one|has_many|belongs_to)/ }
      
      @attributes ||= self.properties.collect do |key, value|
        Ruboss::Generator::GeneratedAttribute.new(key, value)
      end
    end
    
    def self.source_root
      File.join(File.dirname(__FILE__), 'templates', 'ruboss_scaffold')
    end
    
    invoke :ruboss_resource_controller do |generator|
      generator.new(destination_root, options, controller_name)
    end
    
    template :ar_model, :flex_only => false do |t|
      t.source = 'model.rb.erb'
      t.destination = File.join('app', 'models', "#{file_name}.rb")
    end
    
    empty_directory :fixtures, File.join('spec', 'fixtures')
    
    template :fixture, :flex_only => false do |t|
      t.source = 'fixtures.yml.erb'
      t.destination = File.join('spec', 'fixtures', "#{table_name}.yml")
    end
    
    empty_directory :migrations, File.join('schema', 'migrations')
    
    template :migration, :flex_only => false, :skip_migration => false do |t|
      t.source = 'migration.rb.erb'
      t.destination = File.join('schema', 'migrations', "#{migration_file_name}.rb")
    end
    
    template :as_model do |t|
      t.source = 'model.as.erb'
      t.destination = File.join('app', 'flex', base_folder, 'models', "#{class_name}.as")
    end
    
    template :flex_component do |t|
      t.source = 'component.mxml.erb'
      t.destination = File.join('app', 'flex', base_folder, 'components', 'generated', "#{class_name}Box.mxml")
    end

    invoke :ruboss_controller do |generator|
      generator.new(destination_root, options)
    end
    
    def migration_file_name
      current_migration_number = Dir[Dir.pwd+'/schema/migrations/*'].map{|f| File.basename(f) =~ /^(\d+)/; $1}.max
      migration_file_name = format("%03d_%s", (current_migration_number.to_i+1), file_name) + "_migration"
    end
    
    def migration_name
      "#{class_name}Migration"
    end

    desc <<-DESC
      Foobar.
    DESC
  end
  
  add :ruboss_scaffold, RubossScaffoldGenerator
end