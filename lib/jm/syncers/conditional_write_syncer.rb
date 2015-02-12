module JM
  module Syncers
    # Only forward {#push} calls to the wrapped syncer, if a condition holds
    class ConditionalWriteSyncer < Syncer
      def initialize(syncer, condition)
        @syncer = syncer
        @condition = condition
      end

      def push(source, target)
        if @condition.call(source)
          @syncer.push(source, target)
        else
          Success.new(target)
        end
      end

      def pull(source, target)
        @syncer.pull(source, target)
      end
    end
  end
end
