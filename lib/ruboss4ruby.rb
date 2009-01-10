# Sets up all the relevant configuration options and brings together 
# patches for Rails, Merb, ActiveRecord and Data Mapper.
#
# Loads Ruboss specific rake tasks if appropriate.
module Ruboss4Ruby

  # :stopdoc:
  VERSION = '1.1.1'
  RUBOSS_FRAMEWORK_VERSION = '1.1.1'
  LIB_DIR = File.join(File.dirname(__FILE__), 'ruboss4ruby/')
  # :startdoc:

  # Returns the version string for the library.
  #
  def self.version
    VERSION
  end

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

require Ruboss4Ruby::LIB_DIR + 'configuration'

# make sure we're running inside Merb
if defined?(Merb::Plugins)
  Merb::Plugins.add_rakefiles 'ruboss4ruby/tasks'

  Merb::BootLoader.before_app_loads do
    
    if defined?(ActiveRecord::Base)
      Merb.add_mime_type(:fxml,  :to_fxml,  %w[application/xml text/xml application/x-xml], :charset => "utf-8")
      ['active_foo', 'active_record_default_methods'].each { |lib| require Ruboss4Ruby::LIB_DIR + lib }
      Merb::Plugins.add_rakefiles 'ruboss4ruby/active_record_tasks'
    else
      Merb.add_mime_type(:fxml,  :to_xml,  %w[application/xml text/xml application/x-xml], :charset => "utf-8")
      if defined?(Merb::Orms::DataMapper)
        require Ruboss4Ruby::LIB_DIR + 'datamapper_foo'
      end
    end
  end    
elsif defined?(ActionController::Base)
  # if we are not running in Merb, try to hook up Rails
  Mime::Type.register_alias "application/xml", :fxml
  
  ['active_foo', 'active_record_default_methods', 'rails/swf_helper'].each { |lib| require Ruboss4Ruby::LIB_DIR + lib }

  ActionView::Base.send :include, SWFHelper unless ActionView::Base.included_modules.include?(SWFHelper)  

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

  # It is possible to pass metadata with any Ruboss model. This module adds support for
  # extracting that metadata into the standard params hash.
  module Ruboss4RubyController
    private

    # Extract any keys named _metadata from the models in the params hash
    # and put them in the root of the params hash.
    def extract_metadata_from_params
      metadata = {}
      metadata.merge!(params.delete('_metadata')) if params.has_key?('_metadata')
      params.each do |k, v|
        next unless v.respond_to?(:has_key?) and v.has_key?('_metadata')
        metadata.merge!(v.delete('_metadata'))
      end
      params.merge!(metadata) unless metadata.empty?
    end  
  end
  
  module ActiveRecord
    # ActiveRecord named scopes are computed *before* ruboss4ruby gem gets loaded
    # this patch addresses that and makes sure +to_fxml+ calls are properly
    # delegated
    module NamedScope
      # make sure we properly delegate +to_fxml+ calls to the proxy
      class Scope
        delegate :to_fxml, :to => :proxy_found
      end
    end
  end

  ActionController::Base.send :include, Ruboss4RubyController  
  ActionController::Base.send :prepend_before_filter, :extract_metadata_from_params  

  # temporarily disable forgery protection site-wise
  ActionController::Base.allow_forgery_protection = false
end