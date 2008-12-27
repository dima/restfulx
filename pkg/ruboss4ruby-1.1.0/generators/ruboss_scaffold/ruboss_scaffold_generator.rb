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
                                
  attr_accessor :constructor_args
      
  def initialize(runtime_args, runtime_options = {})
    super

    # Name argument is required.
    usage if runtime_args.empty?

    @args = runtime_args.dup
    @name = @args.shift
    @file_name = @name.underscore
    @class_name = @name.camelize
    
    @project_name, @flex_project_name, @command_controller_name, @base_package, @base_folder = extract_names
    
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
      # Generate Flex AS model and MXML component based on the
      # Ruboss templates.
      
      puts @file_name
      
      m.template 'model.as.erb',
        File.join("app", 'flex', base_folder, "models", "#{@class_name}.as"), 
        :assigns => { :resource_controller_name => "#{file_name.pluralize}" }

      m.template 'component.mxml.erb',
        File.join("app", 'flex', base_folder, "components", "generated", "#{@class_name}Box.mxml"), 
        :assigns => { :resource_controller_name => "#{file_name.pluralize}" }

      # Run the rcontroller generator to clobber the
      # RubossCommandController subclass to include the new models.
      m.dependency 'ruboss_controller', [name] + @args, :collision => :force
    end
  end
  
  protected
    def attributes
      @attributes ||= @args.collect do |attribute|
        Ruboss4Ruby::Generator::GeneratedAttribute.new(*attribute.split(":"))
      end
    end
end