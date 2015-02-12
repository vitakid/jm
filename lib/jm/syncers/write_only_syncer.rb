module JM
  module Syncers
    # Wraps another syncer and only forwards {#push} calls
    class WriteOnlySyncer < Syncer
      def initialize(syncer)
        @syncer = syncer
      end

      def push(source, target)
        @syncer.push(source, target)
      end

      def pull(source, target)
        Success.new(source)
      end
    end
  end
end
