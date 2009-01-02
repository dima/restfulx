require 'open-uri'

class RubossConfigGenerator < RubiGen::Base
  include Ruboss4Ruby::Configuration

  def manifest
    record do |m|        
      framework_release = Ruboss4Ruby::RUBOSS_FRAMEWORK_VERSION
      framework_distribution_url = "http://ruboss.com/releases/ruboss-#{framework_release}.swc"
      framework_destination_file = "lib/ruboss-#{framework_release}.swc"
      
      if !options[:skip_framework] && !File.exist?(framework_destination_file)
        puts "fetching #{framework_release} framework binary from: #{framework_distribution_url} ..."
        open(framework_destination_file, "wb").write(open(framework_distribution_url).read)
        puts "done. saved to #{framework_destination_file}"
      end
    end
  end
end