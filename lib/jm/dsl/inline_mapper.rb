module JM
  module DSL
    # Use a block to define a mapper
    #
    # It also wraps the return values in a {Success}, if it is not already a
    # {Result}.
    #
    # @example
    #   InlineMapper.new do
    #     def read(right)
    #     end
    #
    #     def write(left)
    #     end
    #   end
    class InlineMapper < JM::Mapper
      def initialize(&block)
        @klass = Class.new(JM::Mapper)
        @klass.class_eval(&block)
        @mapper = @klass.new
      end

      def read(right)
        Result.wrap(@mapper.read(right))
      end

      def write(left)
        Result.wrap(@mapper.write(left))
      end
    end
  end
end
