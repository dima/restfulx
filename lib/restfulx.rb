# Sets up all the relevant configuration options and brings together 
# patches for Rails, Merb, ActiveRecord and Data Mapper.
#
# Loads RestfulX specific rake tasks if appropriate.
module RestfulX

  # :stopdoc:
  FRAMEWORK_VERSION = '1.2.4'
  LIB_DIR = File.join(File.dirname(__FILE__), 'restfulx/')
  # :startdoc:

  # Utility method used to require all files ending in .rb that lie in the
  # directory below this file that has the same name as the filename passed
  # in. Optionally, a specific _directory_ name can be passed in such that
  # the _filename_ does not have to be equivalent to the directory.
  #
  def self.require_all_libs_relative_to( fname, dir = nil )
    dir ||= ::File.basename(fname, '.*')
    search_me = ::File.expand_path(
        ::File.join(::File.dirname(fname), dir, '*', '*.rb'))

    Dir.glob(search_me).sort.each {|rb| require rb}
  end
end

require RestfulX::LIB_DIR + 'configuration'

# make sure we're running inside Merb
if defined?(Merb::Plugins)
  Merb::Plugins.add_rakefiles RestfulX::LIB_DIR + 'tasks'

  Merb::BootLoader.before_app_loads do
    
    if defined?(ActiveRecord::Base)
      Merb.add_mime_type(:fxml,  :to_fxml,  %w[application/xml text/xml application/x-xml], :charset => "utf-8")
      ['active_foo', 'active_record_default_methods'].each { |lib| require RestfulX::LIB_DIR + lib }
      Merb::Plugins.add_rakefiles RestfulX::LIB_DIR + 'active_record_tasks'
    else
      Merb.add_mime_type(:fxml,  :to_xml,  %w[application/xml text/xml application/x-xml], :charset => "utf-8")
      if defined?(Merb::Orms::DataMapper)
        require RestfulX::LIB_DIR + 'datamapper_foo'
      end
    end
  end    
elsif defined?(ActionController::Base)
  # if we are not running in Merb, try to hook up Rails
  Mime::Type.register_alias "application/xml", :fxml
  
  ['active_foo', 'rails/swf_helper', 'rails/schema_to_yaml'].each { |lib| require RestfulX::LIB_DIR + lib }

  ActionView::Base.send :include, SWFHelper unless ActionView::Base.included_modules.include?(SWFHelper)
  ActiveRecord::Migration.send :include, SchemaToYaml

  # We mess with default +render+ implementation a bit to add support for expressions
  # such as format.fxml { render :fxml => @foo }
  module ActionController
    # Override render to add support for render :fxml
    class Base
      alias_method :old_render, :render unless method_defined?(:old_render)

      # so that we can have handling for :fxml option and write code like
      # format.fxml  { render :fxml => @projects }
      def render(options = nil, extra_options = {}, &block)
        if options.is_a?(Hash) && options[:fxml]
          xml = options[:fxml]
          response.content_type ||= Mime::XML
          render_for_text(xml.respond_to?(:to_fxml) ? xml.to_fxml : xml, options[:status])
        else
          old_render(options, extra_options, &block)
        end
      end
    end
  end
  
  module ActiveRecord
    # ActiveRecord named scopes are computed *before* restfulx gem gets loaded
    # this patch addresses that and makes sure +to_fxml+ calls are properly
    # delegated
    module NamedScope
      # make sure we properly delegate +to_fxml+ calls to the proxy
      class Scope
        delegate :to_fxml, :to => :proxy_found
      end
    end
  end
elsif defined?(DataMapper)
  require RestfulX::LIB_DIR + 'datamapper_foo'
elsif defined?(ActiveRecord::Base)
  require RestfulX::LIB_DIR + 'active_foo'  
end