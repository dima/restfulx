require 'open-uri'

class RxConfigGenerator < RubiGen::Base
  include RestfulX::Configuration

  def manifest
    record do |m|        
      framework_release = RestfulX::VERSION
      framework_distribution_url = "http://restfulx.github.com/releases/restfulx-#{framework_release}.swc"
      framework_destination_file = "lib/restfulx-#{framework_release}.swc"
      
      if !options[:skip_framework] && !File.exist?(framework_destination_file)
        puts "fetching #{framework_release} framework binary from: #{framework_distribution_url} ..."
        open(framework_destination_file, "wb").write(open(framework_distribution_url).read)
        puts "done. saved to #{framework_destination_file}"
      end

      m.dependency 'rx_controller', @args
    end
  end
end