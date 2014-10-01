module JM
  module Mappers
    # Uses the left and right accessor of a pipe for mapping
    class PipeMapper < Mapper
      def initialize(pipe)
        @pipe = pipe
      end

      def read(object)
        target = @pipe.left_factory.create

        @pipe.suck(target, object)
      end

      def write(object)
        target = @pipe.right_factory.create

        @pipe.pump(object, target)
      end
    end
  end
end
