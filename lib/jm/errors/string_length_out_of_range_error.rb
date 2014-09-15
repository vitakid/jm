module JM
  module Errors
    # The length of a string is not in the desired range
    class StringLengthOutOfRangeError < Error
      def initialize(path, min, max)
        super(path, :string_length_out_of_range, min: min, max: max)
      end
    end
  end
end
