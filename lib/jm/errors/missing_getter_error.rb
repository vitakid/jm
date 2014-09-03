module JM
  module Errors
    # Error indicating, that an object misses a getter
    class MissingGetterError < Error
      def initialize(path, object, getter)
        super(path, :missing_getter, object: object, getter: getter)
      end
    end
  end
end
