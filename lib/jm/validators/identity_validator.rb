module JM
  module Validators
    # A validator, that accepts everything
    class IdentityValidator < Validator
      def validate(object)
        Success.new(object)
      end
    end
  end
end
