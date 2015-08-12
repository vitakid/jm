module JM
  module Syncers
    # Wraps another syncer and only forwards {#push} calls
    class PushOnlySyncer < Syncer
      def initialize(syncer)
        @syncer = syncer
      end

      def push(source, target, options = {}, context = {})
        @syncer.push(source, target, options, context)
      end

      def pull(source, target, options = {}, context = {})
        Success.new(source)
      end
    end
  end
end
