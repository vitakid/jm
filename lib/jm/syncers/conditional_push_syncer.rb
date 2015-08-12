module JM
  module Syncers
    # Only forward {#push} calls to the wrapped syncer, if a condition holds
    class ConditionalPushSyncer < Syncer
      def initialize(syncer, condition)
        @syncer = syncer
        @condition = condition
      end

      def push(source, target, options = {}, context = {})
        if @condition.call(source, options, context)
          @syncer.push(source, target, options, context)
        else
          Success.new(target)
        end
      end

      def pull(source, target, options = {}, context = {})
        @syncer.pull(source, target, options, context)
      end
    end
  end
end
