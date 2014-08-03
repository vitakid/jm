module JM
  module Accessors
    # Accesses a hash with a given key
    class HashKeyAccessor < JM::Mapper
      def initialize(key)
        @key = key
      end

      def get(hash)
        hash[@key]
      end

      def set(hash, data)
        hash[@key] = data
      end
    end
  end
end
