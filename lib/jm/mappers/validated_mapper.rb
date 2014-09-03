module JM
  module Mappers
    # Wrap a mapper with {Validators}
    #
    # On both {#read} and {#write} the mapper will first validate, that the
    # input is valid on the origin side, then feed it into the wrapped mapper
    # and then validate, that the output is valid on the target side.
    class ValidatedMapper < Mapper
      # @param [Mapper] mapper Mapper to wrap
      # @param [Validator] left Validator for the left side
      # @param [Validator] right Validator for the right side
      def initialize(mapper, left, right)
        @mapper = mapper
        @left_validator = left
        @right_validator = right
      end

      def read(object)
        @right_validator.validate(object).map do |validated|
          @mapper.read(validated).map do |mapped|
            @left_validator.validate(mapped)
          end
        end
      end

      def write(object)
        @left_validator.validate(object).map do |validated|
          @mapper.write(validated).map do |mapped|
            @right_validator.validate(mapped)
          end
        end
      end
    end
  end
end
