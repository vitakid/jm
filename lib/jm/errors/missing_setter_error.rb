module JM
  module Errors
    # Error indicating, that an object misses a setter
    class MissingSetterError < Error
      def initialize(path, object, setter)
        super(path, :missing_setter, object: object, setter: setter)
      end
    end
  end
end
