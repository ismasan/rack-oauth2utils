module Rack
  module OAuth2Utils
    
    class Middleware
      
      def initialize(app, options = {}, &resolver)
        @app = app
        @realm = options[:realm]
        @logger = options[:logger]
        @resolver = resolver
      end
      
      def call(env)
        request = OAuthRequest.new(env)
        logger = @logger || env["rack.logger"]
        
        # If not oauth header / param, leave it up to the app.
        return @app.call(env) unless request.oauth?
        
        # Fetch identity
        if identity = @resolver.call(request.access_token) # identity found, forward to backend
          env["oauth.identity"] = identity
          logger.info "RO2U: Authorized #{identity}" if logger
        else # invalid token
          logger.info "RO2U: Invalid token" if logger
          return unauthorized(request)
        end
        @app.call(env)
      end
      
      protected
      
      # Returns WWW-Authenticate header.
      def unauthorized(request)
        challenge = 'OAuth realm="%s"' % (@realm || request.host)
        challenge << ', error="invalid_token", error_description="The access token is invalid."'
        return [401, { "WWW-Authenticate" => challenge, 'Content-Type' => 'text/plain' }, ['The access token is invalid.']]
      end
      
    end
    
  end
end
