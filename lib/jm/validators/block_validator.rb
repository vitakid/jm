module JM
  module Validators
    # A validator, that uses a block for validation
    class BlockValidator < Validator
      # @param [Proc] block The block should fulfil the normal contract of
      #   {JM::Validator#validate}
      def initialize(&block)
        @block = block
      end

      def validate(object)
        @block.call(object)
      end
    end
  end
end
