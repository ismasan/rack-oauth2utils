# Wraps Rack::Request to expose Basic and OAuth authentication
# credentials.
# Borrowed from https://github.com/flowtown/rack-oauth2-server
#
module Rack
  module OAuth2Utils
    
    class OAuthRequest < Rack::Request

      AUTHORIZATION_KEYS = %w{HTTP_AUTHORIZATION X-HTTP_AUTHORIZATION X_HTTP_AUTHORIZATION}
      HEADER_FORMAT = /^(oauth|bearer)\s+(.+)/i
      
      # Returns authorization header.
      def authorization_header
        @authorization_header ||= (
          header = AUTHORIZATION_KEYS.inject(nil) { |auth, key| auth || @env[key] }
          
          if header && match = header.match(HEADER_FORMAT)
            match[2]
          else
            nil
          end
        )
      end
      
      def authorization_param
        @authorization_param ||= (self.GET['access_token'] || self.GET['bearer_token'])
      end

      # True if authentication scheme is OAuth.
      def oauth?
        authorization_header || authorization_param
      end

      # If OAuth, returns access token.
      #
      def access_token
        @access_token ||= oauth?
      end
    end
    
  end
end