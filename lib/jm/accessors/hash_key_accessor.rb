module JM
  module Accessors
    # Accesses a hash with a given key
    class HashKeyAccessor < JM::Mapper
      def initialize(key)
        @key = key
      end

      def get(hash)
        if !hash.is_a?(Hash)
          Failure.new(Errors::UnexpectedTypeError.new([], Hash, hash.class))
        elsif !hash.key?(@key)
          Failure.new(Errors::MissingKeyError.new([@key], @key))
        else
          Success.new(hash[@key])
        end
      end

      def set(hash, data)
        if !hash.is_a?(Hash)
          Failure.new(Errors::UnexpectedTypeError.new([], Hash, hash.class))
        else
          hash[@key] = data

          Success.new(hash)
        end
      end
    end
  end
end
