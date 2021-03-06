require File.expand_path(File.dirname(__FILE__) + '/test_helper')

describe Rack::OAuth2Utils::Middleware do
  
  include Rack::Test::Methods
  
  OK_RESPONSE = [200, {'Content-Type' => 'text/plain'}, ['Hello world']]
  FORBIDDEN_RESPONSE = [403, {'Content-Type' => 'text/plain'}, ['Nono']]
  
  IDENTITIES = {
    # token      # identity
    'aaaaa'   => 'ismasan',
    'bbbbb'   => 'sachi'
  }
  
  def app
    @app ||= Rack::Builder.new do
      # Simple token / identity store
      use Rack::OAuth2Utils::Middleware do |access_token|
        IDENTITIES[access_token]
      end
      
      # Public endpoint
      map('/public'){
        run lambda {|env| OK_RESPONSE } 
      }
      # Private, o auth protected
      map('/private'){
        run lambda {|env| 
          if env['oauth.identity']
            OK_RESPONSE
          else
            FORBIDDEN_RESPONSE
          end   
        } 
      }
    end
  end
  
  describe "no token" do
    
    describe 'public resource' do
      before {get '/public'}
      
      it 'should return 200 Ok' do
        last_response.status.must_equal 200
      end
      
      it 'should return body' do
        last_response.body.must_equal 'Hello world'
      end
    end
    
    describe 'private resource' do
      before {get '/private'}
      
      it 'should return 200 Ok' do
        last_response.status.must_equal 403
      end
      
      it 'should return body' do
        last_response.body.must_equal 'Nono'
      end
    end
  end
  
  describe 'with invalid token' do
    
    before {
      header "Authorization", "OAuth invalidtoken"
    }
    
    describe 'public resource' do
      before {get '/public'}
      
      it 'should return 401 Unauthorized' do
        last_response.status.must_equal 401
      end
      
      it 'should return WWW-Authenticate header with realm and error info' do
        last_response.headers['WWW-Authenticate'].must_equal "OAuth realm=\"example.org\", error=\"invalid_token\", error_description=\"The access token is invalid.\""
      end
      
      it 'should have default content type' do
        last_response.headers['Content-Type'].must_equal 'text/plain'
      end
      
      it 'should have default error explanation in the body' do
        last_response.body.must_equal 'The access token is invalid.'
      end
    end
    
    describe 'private resource' do
      before {get '/private'}
      
      it 'should return 401 Unauthorized' do
        last_response.status.must_equal 401
      end
      
      it 'should return WWW-Authenticate header with realm and error info' do
        last_response.headers['WWW-Authenticate'].must_equal "OAuth realm=\"example.org\", error=\"invalid_token\", error_description=\"The access token is invalid.\""
      end
    end
  end
  
  describe ':invalid_token_response' do
    def app
      invalid = [{'Content-Type' => 'application/json'}, ['{"error": "Invalid token"}']]
      Rack::Builder.new do
        # Simple token / identity store
        use Rack::OAuth2Utils::Middleware, :invalid_token_response => invalid do |access_token|
          IDENTITIES[access_token]
        end
        
        # Private, or auth protected
        map('/private'){
          run lambda {|env| 
           OK_RESPONSE   
          } 
        }
      end
    end
    
    before {
      header "Authorization", "OAuth invalidtoken"
      get '/private'
    }
    
    it 'should return 401 Unauthorized' do
      last_response.status.must_equal 401
    end
    
    it 'should return WWW-Authenticate header with realm and error info' do
      last_response.headers['WWW-Authenticate'].must_equal "OAuth realm=\"example.org\", error=\"invalid_token\", error_description=\"The access token is invalid.\""
    end
    
    it 'should have set content type' do
      last_response.headers['Content-Type'].must_equal 'application/json'
    end
    
    it 'should have default error explanation in the body' do
      last_response.body.must_equal '{"error": "Invalid token"}'
    end
    
  end
  
  describe 'with valid token as OAuth header' do
    
    before {
      header "Authorization", "OAuth aaaaa"
    }
    
    describe 'public resource' do
      before {get '/public'}
      
      it 'should return 200 Ok' do
        last_response.status.must_equal 200
      end
      
      it 'should return body' do
        last_response.body.must_equal 'Hello world'
      end
    end
    
    describe 'private resource' do
      before {get '/private'}
      
      it 'should return 200 Ok' do
        last_response.status.must_equal 200
      end
      
      it 'should return body' do
        last_response.body.must_equal 'Hello world'
      end
    end
  end
  
  describe 'with valid token as Bearer header' do
    
    before {
      header "Authorization", "Bearer aaaaa"
    }
    
    describe 'public resource' do
      before {get '/public'}
      
      it 'should return 200 Ok' do
        last_response.status.must_equal 200
      end
      
      it 'should return body' do
        last_response.body.must_equal 'Hello world'
      end
    end
    
    describe 'private resource' do
      before {get '/private'}
      
      it 'should return 200 Ok' do
        last_response.status.must_equal 200
      end
      
      it 'should return body' do
        last_response.body.must_equal 'Hello world'
      end
    end
  end
  
  describe 'with valid token as query param' do
    before {get '/private', 'access_token' => 'aaaaa'}
    
    it 'should return 200 Ok' do
      last_response.status.must_equal 200
    end
    
    it 'should return body' do
      last_response.body.must_equal 'Hello world'
    end
  end
  
  describe 'with alternative valid token as query param named "bearer_token"' do
    before {get '/private', 'access_token' => 'aaaaa'}
    
    it 'should return 200 Ok' do
      last_response.status.must_equal 200
    end
    
    it 'should return body' do
      last_response.body.must_equal 'Hello world'
    end
  end

end