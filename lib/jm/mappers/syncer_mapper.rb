module JM
  module Mappers
    # Uses the source and target factories of a syncer for mapping
    class SyncerMapper < Mapper
      def initialize(syncer)
        @syncer = syncer
      end

      def read(object)
        source = @syncer.source_factory.create

        @syncer.pull(source, object)
      end

      def write(object)
        target = @syncer.target_factory.create

        @syncer.push(object, target)
      end
    end
  end
end
