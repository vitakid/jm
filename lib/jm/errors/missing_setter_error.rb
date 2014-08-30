module JM
  module Errors
    # Error indicating, that an object misses a setter
    class MissingSetterError < Error
      def initialize(object, setter)
        super(:missing_setter, object: object, setter: setter)
      end
    end
  end
end
