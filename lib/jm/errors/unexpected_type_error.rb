module JM
  module Errors
    # Error indicating, that an object has an unexpected type
    class UnexpectedTypeError < Error
      def initialize(expected, actual)
        super(:unexpected_type, expected: expected, actual: actual)
      end
    end
  end
end
