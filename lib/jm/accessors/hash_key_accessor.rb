module JM
  module Accessors
    # Accesses a hash with a given key
    class HashKeyAccessor < JM::Mapper
      def initialize(key, default_value = nil)
        @key = key
        @default_value = default_value
      end

      def get(hash, *_args)
        if !hash.is_a?(Hash)
          Failure.new(Errors::NotAnObjectError.new([]))
        else
          Success.new(hash.fetch(@key, @default_value))
        end
      end

      def set(hash, data, *_args)
        if !hash.is_a?(Hash)
          Failure.new(Errors::NotAnObjectError.new([]))
        else
          hash[@key] = data

          Success.new(hash)
        end
      end
    end
  end
end
