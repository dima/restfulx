module SchemaToYaml
  module Settings
    class Core
      class << self
        def name
          instance._settings.key?("name") ? instance.name : super
        end
        
        def reset!
          @instance = nil
        end
        
      private
        def instance
          @instance ||= new
        end
        
        def method_missing(name, *args, &block)
          instance.send(name, *args, &block)
        end
      end
      
      attr_accessor :_settings
      
      def initialize(name_or_hash = Config.settings_file)
        case name_or_hash
        when Hash
          self._settings = name_or_hash
        when String, Symbol
          root_path = defined?(RAILS_ROOT) ? "#{RAILS_ROOT}/config/" : ""
          file_path = name_or_hash.is_a?(Symbol) ? "#{root_path}#{name_or_hash}.yml" : name_or_hash
          self._settings = YAML.load(ERB.new(File.read(file_path)).result)
          self._settings = _settings[RAILS_ENV] if defined?(RAILS_ENV)
        else
          raise ArgumentError.new("Your settings must be a hash, 
            a symbol representing the name of the .yml file in your config directory,
            or a string representing the abosolute path to your settings file.")
        end
        define_settings!
      end
      
    private
      def method_missing(name, *args, &block)
        raise NoMethodError.new("no configuration was specified for #{name}")
      end
      
      def define_settings!
        return if _settings.nil?
        _settings.each do |key, value|
          case value
          when Hash
            instance_eval <<-"end_eval", __FILE__, __LINE__
              def #{key}
                @#{key} ||= self.class.new(_settings["#{key}"])
              end
            end_eval
          else
            instance_eval <<-"end_eval", __FILE__, __LINE__
              def #{key}
                @#{key} ||= _settings["#{key}"]
              end
            end_eval
          end
        end
      end
    end
  end
end