module Rails
  module Generator
    class GeneratedAttribute
      attr_accessor :name, :type, :column, :flex_name

      def initialize(name, type)
        @name, @type = name, type.to_sym
        @flex_name = name.camelcase(:lower)
        @column = ActiveRecord::ConnectionAdapters::Column.new(name, nil, @type)
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
          when :date, :datetime, :time      then 'Date'
          when :boolean                     then 'Boolean'
          when :float, :decimal             then 'Number'
          else
            'String'
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

class RubossScaffoldGenerator < Rails::Generator::NamedBase
  include Ruboss4Ruby::Configuration 
  
  attr_reader   :project_name, 
                :flex_project_name, 
                :base_package, 
                :base_folder, 
                :command_controller_name

  attr_reader   :belongs_tos, 
                :has_manies,
                :has_ones
    
  attr_reader   :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_underscore_name,
                :controller_singular_name,
                :controller_plural_name
                
  attr_accessor :constructor_args
                  
  alias_method  :controller_file_name,  :controller_underscore_name
  alias_method  :controller_table_name, :controller_plural_name
      
  def initialize(runtime_args, runtime_options = {})
    super
    @project_name, @flex_project_name, @command_controller_name, @base_package, @base_folder = extract_names
    @controller_name = @name.pluralize

    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, 
      @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_underscore_name, @controller_plural_name = inflect_names(base_name)
    
    @controller_singular_name=base_name.singularize
    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end

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
    @args.delete_if { |elt| elt =~ /^(has_one|has_many|belongs_to):/ }
  end
  
  def manifest
    record do |m|
      m.dependency 'scaffold', [name] + @args, :skip_migration => true, :collision => :skip unless options[:flex_only]
      
      # Generate Flex AS model and MXML component based on the
      # Ruboss templates.
      m.template 'model.as.erb',
        File.join("app", "flex", base_folder, "models", "#{@class_name}.as"), 
        :assigns => { :resource_controller_name => "#{file_name.pluralize}" }

      m.template 'component.mxml.erb',
        File.join("app", "flex", base_folder, "components", "generated", "#{@class_name}Box.mxml"), 
        :assigns => { :resource_controller_name => "#{file_name.pluralize}" }
        
      m.template 'controller.rb.erb', File.join("app/controllers", controller_class_path, 
        "#{controller_file_name}_controller.rb"), :collision => :force unless options[:flex_only]
      
      # Create a new generated ActiveRecord model based on the Ruboss templates.
      m.template 'model.rb.erb', File.join("app", "models", "#{file_name}.rb"), 
        :collision => :force unless options[:flex_only]

      unless options[:skip_fixture] 
        m.template 'fixtures.yml.erb',  File.join("test", "fixtures", "#{table_name}.yml"), 
          :collision => :force unless options[:flex_only]
      end
      
      unless options[:skip_migration]
        m.directory 'schema/migration'
        m.migration_template 'migration.rb.erb', 'db/migrate', :assigns => {
          :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}"
        }, :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}" unless options[:flex_only]
      end

      # Run the rcontroller generator to clobber the
      # RubossCommandController subclass to include the new models.
      m.dependency 'ruboss_controller', [name] + @args, :collision => :force
    end
  end
  
  protected    
    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("-f", "--flex-only", "Scaffold Flex code only", 
        "Default: false") { |v| options[:flex_only] = v}
    end
end