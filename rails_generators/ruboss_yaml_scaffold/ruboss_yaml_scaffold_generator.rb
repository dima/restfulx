require 'yaml'
require 'ruboss_on_ruby/configuration'

class RubossYamlScaffoldGenerator < Rails::Generator::Base
  def extract_attrs(line, attrs)
    attrs.each do |key,value|
      if key =~ /\*$/
        #If the key ends in *, it's the label field, so remove
        #the * from the key name and make this the first argument
        #on the line, since that's the convention used by the
        #rscaffold_generator.
        line = "#{key[0..-2]}:#{value}" + line
      elsif value.class == Array
        line << " #{key}:#{value.join(',')}"
      else
        line << " #{key}:#{value}"
      end    
    end
    line
  end
  
  def manifest
    record do |m|
      models = YAML.load(File.open(File.join(RAILS_ROOT, 'db/model.yml'), 'r'))
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
        Rails::Generator::Scripts::Generate.new.run(["ruboss_scaffold"] + line.split, :flex_only => ARGV.include?('flexonly'))
        puts 'done ...'
        sleep 1
      end
      Rails::Generator::Scripts::Generate.new.run(["ruboss_config"], :app_only => true, :skip_framework => ARGV.include?('skipframework'))
    end
  end

  protected
  def banner
    "Usage: #{$0} #{spec.name}" 
  end
end