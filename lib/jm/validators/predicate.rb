module JM
  module Validators
    # A predicate computes the yes-or-no property of validity of an object
    #
    # Because it is the general nature of a validator to be a predicate,
    # {Predicate} should serve all as a base class for most custom validators.
    #
    # @example
    #   Predicate.new(Error.new([], :negative)) do |object|
    #     object >= 0
    #   end
    class Predicate < Validator
      # @param [JM::Error, [JM::Error]] error Errors to return, if the object is
      #   invalid
      # @param block Should return true, if the object is valid
      # @yield [Object] Object to validate
      def initialize(error, &block)
        @error = error
        @block = block
      end

      def validate(object)
        if @block.call(object)
          JM::Success.new(object)
        else
          JM::Failure.new(@error)
        end
      end
    end
  end
end
