module Ruboss4Ruby
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
        else
          'StringProperty'
        end
      end
      
      def gae_default
        @gae_default = case type
        when :integer                then 'default = 0'
        when :date, :time, :datetime then 'auto_now_add = True'
        when :boolean                then 'default = False'
        when :float, :decimal        then 'default = 0'
        else
          ""
        end
      end
    end
  end
end

class RubossScaffoldGenerator < RubiGen::Base
  include Ruboss4Ruby::Configuration 
  
  attr_reader   :project_name, 
                :flex_project_name, 
                :base_package, 
                :base_folder, 
                :command_controller_name

  attr_reader   :belongs_tos, 
                :has_manies,
                :has_ones
    
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
      @base_package, @base_folder = extract_names
    extract_relationships
  end
  
  def manifest
    record do |m|      
      m.template 'model.as.erb',
        File.join("app", 'flex', base_folder, "models", "#{@class_name}.as"), 
        :assigns => { :resource_controller_name => "#{file_name.pluralize}" }

      m.template 'component.mxml.erb',
        File.join("app", 'flex', base_folder, "components", "generated", "#{@class_name}Box.mxml"), 
        :assigns => { :resource_controller_name => "#{file_name.pluralize}" }
        
      if options[:gae]
        m.template 'controller.py.erb', "app/controllers/#{file_name.pluralize}.py"
        m.template 'model.py.erb', "app/models/#{file_name}.py"
      end

      # Run the rcontroller generator to clobber the
      # RubossCommandController subclass to include the new models.
      m.dependency 'ruboss_controller', [name] + @args, :collision => :force, :gae => options[:gae]
    end
  end
  
  protected
  def extract_relationships
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
    
    @args.delete_if { |elt| elt =~ /^(has_one|has_many|belongs_to):/ }
  end

  def attributes
    @attributes ||= @args.collect do |attribute|
      Ruboss4Ruby::Generator::GeneratedAttribute.new(*attribute.split(":"))
    end
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--gae", "Generate Google App Engine Python classes in addition to Ruboss Flex resources.", 
      "Default: false") { |v| options[:gae] = v }
  end
end