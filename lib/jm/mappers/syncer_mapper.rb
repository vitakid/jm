module JM
  module Mappers
    # Uses the left and right accessor of a syncer for mapping
    class SyncerMapper < Mapper
      def initialize(syncer)
        @syncer = syncer
      end

      def read(object)
        target = @syncer.left_factory.create

        @syncer.pull(target, object)
      end

      def write(object)
        target = @syncer.right_factory.create

        @syncer.push(object, target)
      end
    end
  end
end
