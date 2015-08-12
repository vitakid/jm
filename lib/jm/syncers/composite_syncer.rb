module JM
  module Syncers
    # A syncer composed of accessors for the source and target and a mapper
    #
    # The accessors are the syncer ends and the mapper is a filter in between.
    class CompositeSyncer < Syncer
      def initialize(source_accessor: Accessors::NilAccessor.new,
                     mapper: Mappers::IdentityMapper.new,
                     target_accessor: Accessors::NilAccessor.new)
        @source_accessor = source_accessor
        @mapper = mapper
        @target_accessor = target_accessor
      end

      def push(source, target, options = {}, context = {})
        @source_accessor.get(source).map do |read|
          @mapper.write(read, options, context).map do |mapped|
            @target_accessor.set(target, mapped)
          end
        end
      end

      def pull(source, target, options = {}, context = {})
        @target_accessor.get(target).map do |read|
          @mapper.read(read, options, context).map do |mapped|
            @source_accessor.set(source, mapped)
          end
        end
      end
    end
  end
end
