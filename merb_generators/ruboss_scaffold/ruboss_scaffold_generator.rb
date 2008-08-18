require 'ruboss_on_ruby/configuration'

module RubossOnRuby
  module Generator
    class GeneratedAttribute
      attr_accessor :name, :type, :flex_name

      def initialize(name, type)
        @name, @type = name, type.to_sym
        @flex_name = name.camelcase(:lower)      
      end

      def field_type
        @field_type ||= case type
          when :integer, :float, :decimal   then :text_field
          when :datetime, :timestamp, :time then :datetime_select
          when :date                        then :date_select
          when :string                      then :text_field
          when :text                        then :text_area
          when :boolean                     then :check_box
          else
            :text_field
        end      
      end

      def default(prefix = '')
        @default = case type
          when :integer                     then 1
          when :float                       then 1.5
          when :decimal                     then "9.99"
          when :datetime, :timestamp, :time then Time.now.to_s(:db)
          when :date                        then Date.today.to_s(:db)
          when :string                      then prefix + name.camelize + "String"
          when :text                        then prefix + name.camelize + "Text"
          when :boolean                     then false
          else
            ""
        end      
      end
      
      def flex_type
        @flex_type = case type
          when :integer                     then 'int'
          when :string, :text               then 'String'
          when :date, :datetime, :time      then 'Date'
          when :boolean                     then 'Boolean'
          when :float, :decimal             then 'Number'
          else
            '*'
        end
      end
      
      def flex_default(prefix = '')
        @flex_default = case type
          when :integer, :float, :decimal   then '0'
          when :string, :text               then '""'
          when :boolean                     then 'false'
          else
            'null'
        end
      end
    end
  end
end

class RubossScaffoldGenerator < Merb::GeneratorBase
  include RubossOnRuby::Configuration 

  attr_reader   :class_name,
                :file_name,
                :table_name,
                :provided_args, 
                :actual_args
  
  attr_reader   :project_name, 
                :flex_project_name, 
                :base_package, 
                :base_folder, 
                :command_controller_name

  attr_reader   :belongs_tos, 
                :has_manies,
                :has_ones
    
  def initialize(runtime_args, runtime_options = {})
    @base =             File.dirname(__FILE__)
    super
    @project_name, @flex_project_name, @command_controller_name, @base_package, @base_folder = extract_names

    @actual_args = runtime_args
    @provided_args = runtime_args.dup
    @file_name  = actual_args.shift.snake_case
    @table_name = @file_name.pluralize
    @class_name = @file_name.to_const_string

    @belongs_tos = []
    @has_ones = []
    @has_manies = []
    # Figure out has_one, has_many and belongs_to based on args
    @args.each do |arg|
      if arg =~ /^has_one:/
        # arg = "has_one:arg1,arg2", so all the has_one are together
        @has_ones = arg.split(':')[1].split(',')
      elsif arg =~ /^has_many:/
        # arg = "has_many:arg1,arg2", so all the has_many are together 
        @has_manies = arg.split(":")[1].split(",")
      elsif arg =~ /^belongs_to:/ # belongs_to:arg1,arg2
        @belongs_tos = arg.split(":")[1].split(',')
      end
    end
    
    # Remove the has_one and has_many arguments since they are
    # not for consumption by the scaffold generator, and since
    # we have already used them to set the @belongs_tos, @has_ones and
    # @has_manies.
    @actual_args.delete_if { |elt| elt =~ /^(has_one|has_many|belongs_to):/ }
    @provided_args.delete_if { |elt| elt =~ /^(has_one|has_many|belongs_to):/ }
  end

  def manifest
    record do |m|
      @m = m
      
      #singularize the model & pluralize the name of the controller
      model_args = provided_args.dup
      controller_args = provided_args.dup
      
      # normalize the model_args
      model_args[0] = model_args.first.snake_case.gsub("::", "/").split("/").last.singularize
      
      controller_args[0] = controller_args.first.pluralize
      
      m.dependency "ruboss_resource_controller", controller_args, options.dup

      # # Create a new generated ActiveRecord model based on the Ruboss templates.
      m.directory 'app/models'
      m.template 'model.rb.erb', File.join("app", "models", "#{@file_name}.rb"),
        :collision => :force unless options[:flex_only]

      unless options[:skip_fixture] 
        m.directory 'spec/fixtures'
        m.template 'fixtures.yml.erb',  File.join("spec", "fixtures", "#{@table_name}.yml"), 
          :collision => :force unless options[:flex_only]
      end
      
      unless options[:skip_migration]
         m.directory 'schema/migrations'
         current_migration_number = Dir[Dir.pwd+'/schema/migrations/*'].map{|f| File.basename(f) =~ /^(\d+)/; $1}.max
         migration_file_name = format("%03d_%s", (current_migration_number.to_i+1), file_name) + "_migration"
         m.template 'migration.rb.erb', "schema/migrations/#{migration_file_name}.rb", :assigns => {
           :migration_name => "#{@class_name}Migration"        
         } unless options[:flex_only]
       end

       m.dependency "merb_model_test", [@file_name], { :model_file_name => @file_name, :model_class_name => @class_name }

      # Generate Flex AS model and MXML component based on the
      # Ruboss templates.
      m.template 'model.as.erb',
        File.join("app", "flex", base_folder, "models", "#{@class_name}.as"), 
        :assigns => { :resource_controller_name => "#{@table_name}" }

      m.template 'component.mxml.erb',
        File.join("app", "flex", base_folder, "components", "generated", "#{@class_name}Box.mxml"), 
        :assigns => { :resource_controller_name => "#{@table_name}" }

      # Run the rcontroller generator to clobber the
      # RubossCommandController subclass to include the new models.
      m.dependency 'ruboss_controller', [], :collision => :force
    end
  end
  
  protected
    def attributes
      @attributes ||= @args.collect do |attribute|
        RubossOnRuby::Generator::GeneratedAttribute.new(*attribute.split(":"))
      end
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("-f", "--flex-only", "Scaffold Flex code only", 
        "Default: false") { |v| options[:flex_only] = v}
    end

    def banner
      "Usage: #{$0} #{spec.name}" 
    end
end