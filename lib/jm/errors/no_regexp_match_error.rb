module JM
  module Errors
    # A regexp did not match
    class NoRegexpMatchError < Error
      def initialize(path, regexp)
        super(path, :no_regexp_match, regexp: regexp.inspect)
      end
    end
  end
end
