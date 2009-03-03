require 'activesupport'

# Interestingly enough there's no way to *just* upper-case or down-case first letter of a given
# string. Ruby's own +capitalize+ actually downcases all the rest of the characters in the string
# We patch the class to add our own implementation.
class String
  # Upper-case first character of a string leave the rest of the string intact
  def ucfirst
    self[0,1].capitalize + self[1..-1]
  end
  
  # Down-case first character of a string leaving the rest of it intact
  def dcfirst
    self[0,1].downcase + self[1..-1]
  end
end

module RestfulX
  # Computes necessary configuration options from the environment. This can be used in Rails, Merb
  # or standalone from the command line.
  module Configuration
    APP_ROOT = defined?(RAILS_ROOT) ? RAILS_ROOT : defined?(Merb) ? Merb.root : File.expand_path(".")

    # Extract project, package, controller names from the environment. This will respect
    # config/restfulx.yml if it exists, you can override all of the defaults there. The defaults are:
    # - *base-package* same as project name downcased
    # - *controller-name* 'ApplicationController'
    #
    # Here's a sample restfulx.yml file:
    #
    # RestfulX code generation configuration options
    # 
    # By default flex models, commands, controllers and components are genearated into
    # app/flex/<your rails project name> folder. If you'd like to customize the target folder 
    # (to say append a "com" package before your rails project name) uncomment the line below
    # base-package must follow the usual flex package notation (a string separated by ".")
    # 
    # base-package: com.pomodo
    # 
    # Main RestfulX controller is typically named AppicationController. This controller is created in 
    # <base-package>.controllers folder. You can customize the name by uncommenting the following line 
    # and changing the controller name.
    # 
    # controller-name: ApplicationController
    def extract_names(project = nil)
      if project
        project_name = project.camelcase.gsub(/\s/, '')
        project_name_downcase = project_name.downcase
      else
        project_name = APP_ROOT.split("/").last.camelcase.gsub(/\s/, '')
        project_name_downcase = project_name.downcase
      end
            
      # give a chance to override the settings via restfulx.yml
      begin      
        config = YAML.load(File.open("#{APP_ROOT}/config/restfulx.yml"))
        base_package = config['base-package'] || project_name_downcase
        base_folder = base_package.gsub('.', '/').gsub(/\s/, '')
        project_name = config['project-name'].camelcase.gsub(/\s/, '') || project_name
        controller_name = config['controller-name'] || "ApplicationController"
        flex_root = config['flex-root'] || "app/flex"
        distributed = config['distributed'] || false
      rescue
        base_folder = base_package = project_name_downcase
        controller_name = "ApplicationController"
        flex_root = "app/flex"
        distributed = false
      end
      [project_name, project_name_downcase, controller_name, base_package, base_folder, flex_root, distributed]
    end

    # List files ending in *.as (ActionScript) in a given folder
    def list_as_files(dir_name)
      Dir.entries(dir_name).grep(/\.as$/).map { |name| name.sub(/\.as$/, "") }.join(", ")
    end

    # List files ending in *.mxml in a given folder
    def list_mxml_files(dir_name)
      Dir.entries(dir_name).grep(/\.mxml$/).map { |name| name.sub(/\.mxml$/, "") }
    end
  end
end