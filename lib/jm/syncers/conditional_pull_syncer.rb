module JM
  module Syncers
    # Only forward {#pull} calls to the wrapped syncer, if a condition holds
    class ConditionalPullSyncer < Syncer
      def initialize(syncer, condition)
        @syncer = syncer
        @condition = condition
      end

      def push(source, target, options = {}, context = {})
        @syncer.push(source, target, options, context)
      end

      def pull(source, target, options = {}, context = {})
        if @condition.call(target, options, context)
          @syncer.pull(source, target, options, context)
        else
          Success.new(source)
        end
      end
    end
  end
end
