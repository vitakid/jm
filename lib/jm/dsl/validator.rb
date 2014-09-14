module JM
  module DSL
    # A DSL for creating validators
    #
    # In general it is very similar to {DSL::Mapper}. It is all based on the
    # {#validator} method, that can be used to directly register
    # validators. Other methods are in general short hands for {#validator}
    # calls.
    #
    # You are supposed to subclass this class, configure your validator with the
    # available configuration methods and extend the DSL to fit your needs.
    class Validator < JM::Validator
      def initialize
        @validators = []
      end

      # Register a validator
      #
      # @param [JM::Validator] validator
      def validator(validator)
        @validators << validator
      end

      # Define a validator with a block
      #
      # @example Verifying, that a string has at least 6 characters
      #   inline do
      #     if string.length > 5
      #       JM::Success.new(string)
      #     else
      #       JM::Failure.new(JM::Error.new([], :too_short))
      #     end
      #   end
      # @param block Definition for {JM::Validator#validate}
      def inline(&block)
        validator(Validators::BlockValidator.new(&block))
      end

      # Define a predicate
      #
      # @example Verifying, that a string has at least 6 characters
      #   predicate(JM::Error.new([], :too_short)) do |string|
      #     string.length > 5
      #   end
      # @param [JM::Error, [JM::Error]] errors Errors to fail with, if the
      #   predicate fails
      # @param block Should return true iff the value is **valid**
      def predicate(errors, &block)
        validator(Validators::Predicate.new(errors, &block))
      end

      def regexp(regexp)
        validator(Validators::RegexpValidator.new(regexp))
      end

      # Validate an object by applying the registered validators
      #
      # Validators are applied in registration order and validation fails with
      # the first failure or succeeds, if all validations succeed.
      def validate(object)
        @validators.reduce(Success.new(object)) do |result, validator|
          result.map do |value|
            validator.validate(value)
          end
        end
      end
    end
  end
end
