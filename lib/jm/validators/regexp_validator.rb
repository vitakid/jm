module JM
  module Validators
    # Validates, that the input matches a regular expression
    class RegexpValidator < Predicate
      def initialize(regexp)
        super(Errors::NoRegexpMatchError.new([], regexp)) do |value|
          regexp.match(value)
        end
      end
    end
  end
end
