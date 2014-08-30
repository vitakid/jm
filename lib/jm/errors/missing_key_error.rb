module JM
  module Errors
    # Error indicating, that a hash is missing a key
    class MissingKeyError < Error
      def initialize(key)
        super(:missing_key, key: key)
      end
    end
  end
end
