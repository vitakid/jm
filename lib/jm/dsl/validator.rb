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
      # @param block Definition for {JM::Validator#validate}
      def inline(&block)
        validator(Validators::BlockValidator.new(&block))
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
