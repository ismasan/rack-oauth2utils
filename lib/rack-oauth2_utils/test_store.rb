require 'pstore'
module Rack
  module OAuth2Utils
    
    # Test persistent store. Stores to FS using PStore
    # Not meant for production!
    #
    class TestStore
      def initialize(file_path = '.')
        @store = PStore.new(file_path)
      end

      def []=(key, value)
        @store.transaction do
          @store[key] = value
        end
      end

      def [](key)
        @store.transaction do
          @store[key]
        end
      end

      def delete(key)
        @store.transaction do
          @store.delete(key)
        end
      end
      
      def roots
        @store.transaction do
          @store.roots
        end
      end
    end
    
  end
end
