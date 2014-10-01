module JM
  module Pipes
    # Wraps another pipe and only forwards {#pump} calls
    class ReadOnlyPipe < Pipe
      def initialize(pipe)
        @pipe = pipe
      end

      def pump(source, target)
        @pipe.pump(source, target)
      end

      def suck(source, target)
        Success.new(source)
      end
    end
  end
end
