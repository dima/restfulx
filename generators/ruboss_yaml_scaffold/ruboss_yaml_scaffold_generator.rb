require 'yaml'

class RubossYamlScaffoldGenerator < RubiGen::Base
  include Ruboss4Ruby::Configuration

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
      models = YAML.load(File.open(File.join(APP_ROOT, 'db/model.yml'), 'r'))
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
        puts 'running: ruboss_scaffold ' + line
        RubiGen::Scripts::Generate.new.run(["ruboss_scaffold"] + line.split)
        puts 'done ...'
        sleep 1
      end
      RubiGen::Scripts::Generate.new.run(["ruboss_main_app"])
    end
  end

  protected
  def banner
    "Usage: #{$0} #{spec.name}" 
  end
end