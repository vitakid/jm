module JM
  module Pipes
    # Only forward {#unpipe} calls to the wrapped pipe, if a condition holds
    class ConditionalReadPipe < Pipe
      def initialize(pipe, condition)
        @pipe = pipe
        @condition = condition
      end

      def pipe(source, target)
        @pipe.pipe(source, target)
      end

      def unpipe(source, target)
        if @condition.call(target)
          @pipe.unpipe(source, target)
        end
      end
    end
  end
end
