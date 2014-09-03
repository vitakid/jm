module JM
  module Errors
    # Error indicating, that an object has an unexpected type
    class UnexpectedTypeError < Error
      def initialize(path, expected, actual)
        super(path, :unexpected_type, expected: expected, actual: actual)
      end
    end
  end
end
