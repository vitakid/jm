module JM
  module Pipes
    # A pipe composed of accessors for the source and target and a mapper
    #
    # The accessors are the pipe ends and the mapper is a filter in between.b r
    class CompositePipe < Pipe
      def initialize(source_accessor: Accessors::NilAccessor.new,
                     mapper: Mappers::IdentityMapper.new,
                     target_accessor: Accessors::NilAccessor.new)
        @source_accessor = source_accessor
        @mapper = mapper
        @target_accessor = target_accessor
      end

      def pipe(source, target)
        value = @mapper.write(@source_accessor.get(source))

        @target_accessor.set(target, value)
      end

      def unpipe(source, target)
        value = @mapper.read(@target_accessor.get(target))

        @source_accessor.set(source, value)
      end
    end
  end
end
