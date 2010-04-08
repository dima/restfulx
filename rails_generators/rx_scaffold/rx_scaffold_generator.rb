require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'restfulx') if !defined?(RestfulX)

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

      def flex_default
        @flex_default = case type
        when :integer                 then '0'
        when :date, :datetime, :time  then 'new Date'
        when :boolean                 then 'false'
        when :float, :decimal         then 'new Number'
        else
          "\"\""
        end
      end
    end
    module Commands
      class Create
        include SchemaToRxYaml
      end
    end
  end
end

class RxScaffoldGenerator < Rails::Generator::NamedBase
  include RestfulX::Configuration
  include SchemaToRxYaml
  
  attr_reader   :project_name, 
                :flex_project_name, 
                :base_package, 
                :base_folder, 
                :command_controller_name,
                :flex_root,
                :distributed

  attr_reader   :belongs_tos, 
                :has_manies,
                :has_ones,
                :attachment_field,
                :has_many_through,
                :polymorphic,
                :tree_model,
                :layout,
                :ignored_fields,
                :args_for_generation
    
  attr_reader   :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_underscore_name,
                :controller_singular_name,
                :controller_plural_name
                                  
  alias_method  :controller_file_name,  :controller_underscore_name
  alias_method  :controller_table_name, :controller_plural_name
      
  def initialize(runtime_args, runtime_options = {})
    super
    @project_name, @flex_project_name, @command_controller_name, @base_package, @base_folder, @flex_root, 
      @distributed = extract_names
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
    extract_relationships
  end
  
  def manifest
    record do |m|
      unless options[:flex_view_only]
        m.template 'model.as.erb',
          File.join("#{@flex_root}", base_folder, "models", "#{@class_name}.as"), 
          :assigns => { :resource_controller_name => "#{file_name.pluralize}" }, :collision => options[:collision]
          
        m.template "controllers/#{RxSettings.controller_pattern}.rb.erb", File.join("app/controllers", 
          controller_class_path, "#{controller_file_name}_controller.rb"), :collision => options[:collision] unless options[:flex_only]
        
        m.template 'model.rb.erb', File.join("app", "models", "#{file_name}.rb"), :collision => options[:collision] unless options[:flex_only]
      end
        
      if @layout.size > 0
        m.template "layouts/#{@layout}.erb",
          File.join("#{@flex_root}", base_folder, "views", "generated", "#{@class_name}Box.mxml"), 
          :assigns => { :resource_controller_name => "#{file_name.pluralize}" }, :collision => options[:collision]
      else
        m.template "layouts/#{RxSettings.layouts.default}.erb",
          File.join("#{@flex_root}", base_folder, "views", "generated", "#{@class_name}Box.mxml"), 
          :assigns => { :resource_controller_name => "#{file_name.pluralize}" }, :collision => options[:collision]
      end

      unless options[:skip_fixture] 
        m.template 'fixtures.yml.erb',  File.join("test", "fixtures", "#{table_name}.yml"), 
          :collision => :force unless options[:flex_only]
      end
      
      unless options[:skip_migration]
        FileUtils.rm Dir.glob("db/migrate/[0-9]*_create_#{file_path.gsub(/\//, '_').pluralize}.rb"), :force => true        
        m.migration_template 'migration.rb.erb', 'db/migrate', :assigns => {
          :migration_name => "Create#{file_path.gsub(/\//, '_').pluralize.camelcase.gsub(/::/, '')}"
        }, :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}" unless options[:flex_only]
      end

      m.directory(File.join('test/functional', controller_class_path))
      m.directory(File.join('test/unit', class_path))
      m.directory(File.join('test/unit/helpers', class_path))

      m.template('functional_test.rb', File.join('test/functional', controller_class_path, "#{controller_file_name}_controller_test.rb"))
      m.template('helper_test.rb',     File.join('test/unit/helpers',    controller_class_path, "#{controller_file_name}_helper_test.rb"))

      if File.open('config/routes.rb').grep(/^\s*map.resources :#{controller_file_name}/).empty?
        m.route_resources controller_file_name
      end

      m.dependency 'rx_controller', [name] + @args, :collision => :force
    end
  end
  
  protected
  def extract_relationships
    # arrays
    @belongs_tos = []
    @has_ones = []
    @has_manies = []
    @attachment_field = []
    @polymorphic = []
    @tree_model = []
    @layout = []
    @ignored_fields = []
    
    # hashes
    @has_many_through = {}

    @args.each do |arg|
      # arrays
      if arg =~ /^has_one:/
        @has_ones = arg.split(':')[1].split(',')
      elsif arg =~ /^has_many:/
        @has_manies = arg.split(":")[1].split(",")
      elsif arg =~ /^belongs_to:/
        @belongs_tos = arg.split(":")[1].split(',')
      elsif arg =~ /^attachment_field:/
        @attachment_field = arg.split(":")[1].split(',')
      elsif arg =~ /^polymorphic:/
        @polymorphic = arg.split(":")[1].split(',')
      elsif arg =~ /^tree_model:/
        @tree_model = arg.split(":")[1].split(',')
      elsif arg =~ /^layout:/
        @layout = arg.split(":")[1].split(',')
      elsif arg =~ /^ignored_fields:/
        @ignored_fields = arg.split(":")[1].split(',')
      # hashes
      elsif arg =~ /^has_many_through:/
        hmt_arr = arg.split(":")[1].split(',')
        @has_many_through[hmt_arr.first] = hmt_arr.last
      end
    end
    
    # delete special fields from @args ivar
    %w(has_one has_many belongs_to attachment_field has_many_through 
      polymorphic tree_model layout ignored_fields).each do |special_field|
      @args.delete_if { |f| f =~ /^(#{special_field}):/ }
    end
    
    @args_for_generation = @args.clone
    
    # delete ignored_fields from @args ivar
    @ignored_fields.each do |ignored|
      @args.delete_if { |f| f =~ /^(#{ignored}):/ }
    end
    
  end
  
  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("-f", "--flex-only", "Only generate the Flex/AIR files", 
      "Default: false") { |v| options[:flex_only] = v }
    opt.on("-r", "--rails-only", "Only generate the Rails files", 
      "Default: false") { |v| options[:rails_only] = v }
    opt.on("-fv", "--flex-view-only", "Only generate the Flex component files", 
      "Default: false") { |v| options[:flex_view_only] = v }
  end
end
