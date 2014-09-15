module JM
  module Validators
    # Validate, that the length of string lies in a certain range
    class LengthInRangeValidator < Predicate
      def initialize(range)
        error = Errors::StringLengthOutOfRangeError.new(
          [], range.min, range.max)

        super(error) do |string|
          range.include?(string.length)
        end
      end
    end
  end
end
