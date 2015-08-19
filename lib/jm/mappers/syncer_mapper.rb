module JM
  module Mappers
    # Uses the source and target factories of a syncer for mapping
    class SyncerMapper < Mapper
      def initialize(syncer)
        @syncer = syncer
      end

      def read(object, options = {}, context = {})
        source = @syncer.source_factory.create

        @syncer.pull(source, object, options, context)
      end

      def write(object, options = {}, context = {})
        target = @syncer.target_factory.create

        @syncer.push(object, target, options, context)
      end
    end
  end
end
