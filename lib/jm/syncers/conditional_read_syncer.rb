module JM
  module Syncers
    # Only forward {#pull} calls to the wrapped syncer, if a condition holds
    class ConditionalReadSyncer < Syncer
      def initialize(syncer, condition)
        @syncer = syncer
        @condition = condition
      end

      def push(source, target)
        @syncer.push(source, target)
      end

      def pull(source, target)
        if @condition.call(target)
          @syncer.pull(source, target)
        else
          Success.new(source)
        end
      end
    end
  end
end
