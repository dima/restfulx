# SchemaToYaml settings
module SchemaToYaml
  module Settings
    class Config
      class << self
        def configure
          yield self
        end

        def settings_file
          @settings_file ||= :restfulx
        end
        attr_writer :settings_file
      end
    end
  end
end