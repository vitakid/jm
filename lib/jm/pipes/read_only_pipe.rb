module JM
  module Pipes
    # Wraps another pipe and only forwards {#pipe} calls
    class ReadOnlyPipe < Pipe
      def initialize(pipe)
        @pipe = pipe
      end

      def pipe(source, target)
        @pipe.pipe(source, target)
      end

      def unpipe(source, target)
      end
    end
  end
end
