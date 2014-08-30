module JM
  module DSL
    # Use a block to define a mapper
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
        @mapper.read(right)
      end

      def write(left)
        @mapper.write(left)
      end
    end
  end
end
