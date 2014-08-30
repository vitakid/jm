module JM
  module DSL
    # Use a block to define an accessor
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
        @accessor.get(object)
      end

      def set(object, value)
        @accessor.set(object, value)
      end
    end
  end
end
