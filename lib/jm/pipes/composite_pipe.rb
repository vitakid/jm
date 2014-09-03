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
        @source_accessor.get(source).map do |read|
          @mapper.write(read).map do |mapped|
            @target_accessor.set(target, mapped)
          end
        end
      end

      def slurp(source, target)
        @target_accessor.get(target).map do |read|
          @mapper.read(read).map do |mapped|
            @source_accessor.set(source, mapped)
          end
        end
      end
    end
  end
end
