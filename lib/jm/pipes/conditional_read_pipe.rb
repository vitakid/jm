module JM
  module Pipes
    # Only forward {#suck} calls to the wrapped pipe, if a condition holds
    class ConditionalReadPipe < Pipe
      def initialize(pipe, condition)
        @pipe = pipe
        @condition = condition
      end

      def pump(source, target)
        @pipe.pump(source, target)
      end

      def suck(source, target)
        if @condition.call(target)
          @pipe.suck(source, target)
        else
          Success.new(source)
        end
      end
    end
  end
end
