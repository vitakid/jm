module JM
  module Pipes
    # Only forward {#pump} calls to the wrapped pipe, if a condition holds
    class ConditionalWritePipe < Pipe
      def initialize(pipe, condition)
        @pipe = pipe
        @condition = condition
      end

      def pump(source, target)
        if @condition.call(source)
          @pipe.pump(source, target)
        else
          Success.new(target)
        end
      end

      def suck(source, target)
        @pipe.suck(source, target)
      end
    end
  end
end
