class String
  def capitalize_without_downcasing
    self[0,1].capitalize + self[1..-1]
  end
  def downcase_first_letter
    self[0,1].downcase + self[1..-1]
  end
end

module RubossOnRuby
  module Configuration
    APP_ROOT = defined?(RAILS_ROOT) ? RAILS_ROOT : Merb.root

    def extract_names
      project_name = APP_ROOT.split("/").last.capitalize
      project_name_downcase = project_name.downcase

      begin      
        config = YAML.load(File.open("#{APP_ROOT}/config/ruboss.yml"))
        base_package = config['base-package'] || project_name_downcase
        base_folder = base_package.gsub('.', '/')
        controller_name = config['controller-name'] || "#{project_name}Controller"
      rescue
        base_folder = base_package = project_name_downcase
        controller_name = "#{project_name}Controller"
      end
      [project_name, project_name_downcase, controller_name, base_package, base_folder]
    end

    def list_as_files(dir_name)
      Dir.entries(dir_name).grep(/\.as$/).map { |name| name.sub(/\.as$/, "") }.join(", ")
    end

    def list_mxml_files(dir_name)
      Dir.entries(dir_name).grep(/\.mxml$/).map { |name| name.sub(/\.mxml$/, "") }
    end
  end
end