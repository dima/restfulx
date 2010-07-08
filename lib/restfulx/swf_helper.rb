# Adds a little helper to make it easier empbedding SWFs in ERB templates.
module RestfulX
  module SWFHelper
    # Creates a swfObject Javascript call.  You must include swfobject.js to use this.
    # See http://code.google.com/p/swfobject/wiki/documentation for full details and documentation
    # of the swfobject js library.
    def swfobject(swf_url, params = {})
      params.reverse_merge!({:width => '100%',
                             :height => '100%',
                             :id => 'flashContent',
                             :version => '9.0.0',
                             :express_install_swf => '/expressInstall.swf',
                             :flash_vars => nil,
                             :params => { },
                             :attributes => { },
                             :create_div => false, 
                             :include_authenticity_token => true,
                             :include_session_token => true
                            })                       
      arg_order = [:id, :width, :height, :version, :express_install_swf]
      js_params = ["'#{swf_url}'"]
      js_params += arg_order.collect {|arg| "'#{params[arg]}'" }
    
      # Add authenticity_token and the session key to flashVars.  This will only work if flashVars is a Hash or nil
      # If it's a string representing the name of a Javascript variable, then you need to add them yourself 
      # like this:
      # <script>
      #   ... other code that defines flashVars and sets some of its parameters
      #   flashVars['authenticity_token'] = <%= form_authenticity_token -%>
      #   flashVars['session_token'] = <%= session.session_id -%>
      # </script>
      params[:flash_vars] ||= {}
      if params[:flash_vars].is_a?(Hash)
        if params[:include_authenticity_token] && ActionController::Base.allow_forgery_protection
          params[:flash_vars].reverse_merge!(:authenticity_token => form_authenticity_token)
        end
        if params[:include_session_token]
          if RAILS_GEM_VERSION =~ /^2.3/
            params[:flash_vars].reverse_merge!(:session_token => request.session_options[:id])
          else
            params[:flash_vars].reverse_merge!(:session_token => session.session_id)
          end
        end        
      end          
    
      js_params += [params[:flash_vars], params[:params], params[:attributes]].collect do |hash_or_string|
        if hash_or_string.is_a?(Hash)
          hash_or_string.to_json
        else # If it's not a hash, then it should be a string giving the name of the Javascript variable to use
          hash_or_string
        end
      end.compact

      swf_tag = javascript_tag do 
        "swfobject.embedSWF(#{js_params.join(',')})"
      end 
      swf_tag += content_tag(:div, nil, :id => params[:id]) if params[:create_div]    
      swf_tag
    end
  end
end
