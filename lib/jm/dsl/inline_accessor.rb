module JM
  module DSL
    # Use a block to define an accessor
    #
    # It also wraps the return value in a {Success}, if it is not already a
    # {Result}.
    #
    # @example
    #   InlineAccessor.new do
    #     def get(object)
    #     end
    #
    #     def set(object, value)
    #     end
    #   end
    class InlineAccessor < Accessor
      def initialize(&block)
        @klass = Class.new(Accessor)
        @klass.class_eval(&block)
        @accessor = @klass.new
      end

      def get(object)
        Result.wrap(@accessor.get(object))
      end

      def set(object, value)
        Result.wrap(@accessor.set(object, value))
      end
    end
  end
end
