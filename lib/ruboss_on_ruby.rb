#$:.unshift(File.dirname(__FILE__)) unless
#  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

# Merb specific handling
# make sure we're running inside Merb
if defined?(Merb::Plugins)
  # Merb gives you a Merb::Plugins.config hash...feel free to put your stuff in your piece of it
  Merb::Plugins.config[:ruboss_merb_integration] = {
    #:chickens => false
  }

  Merb::BootLoader.before_app_loads do
    Merb.add_mime_type(:fxml,  :to_fxml,  %w[application/xml text/xml application/x-xml], :charset => "utf-8")

    require 'ruboss_on_ruby/version'
    require 'ruboss_on_ruby/configuration'
    require 'ruboss_on_ruby/active_foo' if defined?(ActiveRecord::Base)
  end
  
  # TODO: can we find out if use_orm :activerecord is on and only then load active record specific tasks?
  Merb::Plugins.add_rakefiles "ruboss_on_ruby/tasks", "ruboss_on_ruby/active_record_tasks"  
else  
  # if we are not running in Merb, we've got to be running in Rails
  Mime::Type.register_alias "application/xml", :fxml

  require 'ruboss_on_ruby/version'
  require 'ruboss_on_ruby/configuration'
  require 'ruboss_on_ruby/active_foo'

  module ActionController
    class Base
      alias_method :old_render, :render

      # so that we can have handling for :fxml option and write code like
      # format.fxml  { render :fxml => @projects }
      def render(options = nil, extra_options = {}, &block)
        if xml = options[:fxml]
          response.content_type ||= Mime::XML
          render_for_text(xml.respond_to?(:to_fxml) ? xml.to_fxml : xml, options[:status])
        else
          old_render(options, extra_options, &block)
        end
      end
    end
  end

  module RubossOnRubyController
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

  # temporarily disable forgery protection site-wise
  ActionController::Base.allow_forgery_protection = false

  ActionController::Base.send :include, RubossOnRubyController
  ActionController::Base.send :prepend_before_filter, :extract_metadata_from_params
end