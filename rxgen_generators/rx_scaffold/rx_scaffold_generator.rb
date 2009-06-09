module RestfulX
  module Generator
    class GeneratedAttribute
      attr_accessor :name, :type, :flex_name

      def initialize(name, type)
        @name, @type = name, type.to_sym
        @flex_name = name.camelcase(:lower)
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
      
      def gae_type
        @gae_type = case type
        when :integer     then 'IntegerProperty'
        when :date        then 'DateProperty'
        when :time        then 'TimeProperty'
        when :datetime    then 'DateTimeProperty'
        when :boolean     then 'BooleanProperty'
        when :text        then 'TextProperty'
        when :float, :decimal then 'FloatProperty'
        else
          'StringProperty'
        end
      end
      
      def gae_default
        @gae_default = case type
        when :integer                then 'default = 0'
        when :date, :time, :datetime then 'auto_now_add = True'
        when :boolean                then 'default = False'
        when :float, :decimal        then 'default = 0.0'
        else
          ""
        end
      end
    end
  end
end

class RxScaffoldGenerator < RubiGen::Base
  include RestfulX::Configuration 
  
  attr_reader   :project_name, 
                :flex_project_name, 
                :base_package, 
                :base_folder, 
                :command_controller_name,
                :flex_root

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
    
  attr_reader   :name,
                :class_name,
                :file_name
                                      
  def initialize(runtime_args, runtime_options = {})
    super

    # Name argument is required.
    usage if runtime_args.empty?

    @args = runtime_args.dup
    @name = @args.shift
    @file_name = @name.underscore
    @class_name = @name.camelize
    
    @project_name, @flex_project_name, @command_controller_name, 
      @base_package, @base_folder, @flex_root = extract_names
    extract_relationships
  end
  
  def manifest
    record do |m|   
      m.template 'model.as.erb',
        File.join("#{flex_root}", base_folder, "models", "#{@class_name}.as"), 
        :assigns => { :resource_controller_name => "#{file_name.pluralize}" }

      if @layout.size > 0
        m.template "layouts/#{@layout}.erb",
          File.join("#{@flex_root}", base_folder, "views", "generated", "#{@class_name}Box.mxml"), 
          :assigns => { :resource_controller_name => "#{file_name.pluralize}" }
      else
        m.template "layouts/#{RxSettings.layouts.default}.erb",
          File.join("#{@flex_root}", base_folder, "views", "generated", "#{@class_name}Box.mxml"), 
          :assigns => { :resource_controller_name => "#{file_name.pluralize}" }
      end
        
      if options[:gae]
        m.template 'controller.py.erb', "app/controllers/#{file_name.pluralize}.py"
        m.template 'model.py.erb', "app/models/#{file_name}.py"
      end

      m.dependency 'rx_controller', [name] + @args, :collision => :force, :gae => options[:gae]
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

  def attributes
    @attributes ||= @args.collect do |attribute|
      RestfulX::Generator::GeneratedAttribute.new(*attribute.split(":"))
    end
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--gae", "Generate Google App Engine Python classes in addition to RestfulX Flex resources.", 
      "Default: false") { |v| options[:gae] = v }
  end
end