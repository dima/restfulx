require 'yaml'
require 'ruboss_on_ruby/configuration'

class RubossYamlScaffoldGenerator < Merb::GeneratorBase
  include RubossOnRuby::Configuration

  def initialize(runtime_args, runtime_options = {})
    runtime_args.push ""
    super
  end

  def extract_attrs(line, attrs)
    attrs.each do |key,value|
      if value.class == Array
        line << " #{key}:#{value.join(',')}"
      else
        line << " #{key}:#{value}"
      end    
    end
    line
  end
  
  def manifest
    record do |m|
      models = YAML.load(File.open(File.join(APP_ROOT, 'schema/model.yml'), 'r'))
      models.each do |model|
        line = ""
        attrs = model[1]
        if attrs.class == Array
          attrs.each do |elm|
            line = extract_attrs(line, elm)
          end
        else
          line = extract_attrs(line, attrs)
        end
        line = model[0].camelcase + " " + line
        line = '--flex-only ' + line if ARGV.include?('flexonly')
        puts 'running: ruboss_scaffold ' + line
        Merb::ComponentGenerator.run "ruboss_scaffold", line.split(" "), "ruboss_scaffold", "generate"
        puts 'done ...'
        sleep 1
      end
      config_args = ['--main-only']
      config_args << '--skip-framework' if ARGV.include?('skipframework')
      Merb::ComponentGenerator.run "ruboss_config", config_args, "ruboss_config", "generate"
    end
  end

  protected
  def banner
    "Usage: #{$0} #{spec.name}" 
  end
end