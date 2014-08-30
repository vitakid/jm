module JM
  module Pipes
    # Only forward {#slurp} calls to the wrapped pipe, if a condition holds
    class ConditionalReadPipe < Pipe
      def initialize(pipe, condition)
        @pipe = pipe
        @condition = condition
      end

      def pipe(source, target)
        @pipe.pipe(source, target)
      end

      def slurp(source, target)
        if @condition.call(target)
          @pipe.slurp(source, target)
        else
          Success.new(source)
        end
      end
    end
  end
end
