module JM
  module Pipes
    # Only forward {#pipe} calls to the wrapped pipe, if a condition holds
    class ConditionalWritePipe < Pipe
      def initialize(pipe, condition)
        @pipe = pipe
        @condition = condition
      end

      def pipe(source, target)
        if @condition.call(source)
          @pipe.pipe(source, target)
        end
      end

      def unpipe(source, target)
        @pipe.unpipe(source, target)
      end
    end
  end
end