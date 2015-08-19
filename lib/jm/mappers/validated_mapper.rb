module JM
  module Mappers
    # Wrap a mapper with {Validators}
    #
    # On both {#read} and {#write} the mapper will first validate, that the
    # input is valid on the source side, then feed it into the wrapped mapper
    # and then validate, that the output is valid on the target side.
    class ValidatedMapper < Mapper
      # @param [Mapper] mapper Mapper to wrap
      # @param [Validator] source_validator Validator for the source side
      # @param [Validator] target_validator Validator for the target side
      def initialize(mapper, source_validator, target_validator)
        @mapper = mapper
        @source_validator = source_validator
        @target_validator = target_validator
      end

      def read(object, options = {}, context = {})
        @target_validator.validate(object).map do |validated|
          @mapper.read(validated, options, context).map do |mapped|
            @source_validator.validate(mapped)
          end
        end
      end

      def write(object, options = {}, context = {})
        @source_validator.validate(object).map do |validated|
          @mapper.write(validated, options, context).map do |mapped|
            @target_validator.validate(mapped)
          end
        end
      end
    end
  end
end
