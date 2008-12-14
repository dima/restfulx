class String
  def capitalize_without_downcasing
    self[0,1].capitalize + self[1..-1]
  end
  
  def downcase_first_letter
    self[0,1].downcase + self[1..-1]
  end
  
  def camelcase(first_letter = :upper)
    case first_letter
      when :upper then self.camelize(true)
      when :lower then self.camelize(false)
    end
  end

  def camelize(first_letter_in_uppercase = true)
    if first_letter_in_uppercase
      self.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    else
      self[0,1].downcase + self.camelize[1..-1]
    end
  end

  def underscore
    self.gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase
  end
end

module Ruboss4Ruby
  module Configuration
    APP_ROOT = defined?(RAILS_ROOT) ? RAILS_ROOT : Merb.root

    def extract_names
      project_name = APP_ROOT.split("/").last.camelcase.gsub(/\s/, '')
      project_name_downcase = project_name.downcase

      begin      
        config = YAML.load(File.open("#{APP_ROOT}/config/ruboss.yml"))
        base_package = config['base-package'] || project_name_downcase
        base_folder = base_package.gsub('.', '/').gsub(/\s/, '')
        controller_name = config['controller-name'] || "ApplicationController"
      rescue
        base_folder = base_package = project_name_downcase
        controller_name = "ApplicationController"
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