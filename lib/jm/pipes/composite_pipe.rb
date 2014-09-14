module JM
  module Pipes
    # A pipe composed of accessors for the source and target and a mapper
    #
    # The accessors are the pipe ends and the mapper is a filter in between.
    class CompositePipe < Pipe
      def initialize(source_accessor: Accessors::NilAccessor.new,
                     mapper: Mappers::IdentityMapper.new,
                     target_accessor: Accessors::NilAccessor.new,
                     optional: false)
        @source_accessor = source_accessor
        @mapper = mapper
        @target_accessor = target_accessor
        @optional = optional
      end

      def pipe(source, target)
        @source_accessor.get(source).map do |read|
          @mapper.write(read).map do |mapped|
            @target_accessor.set(target, mapped)
          end
        end
      end

      def slurp(source, target)
        read_result = @target_accessor.get(target)

        case read_result
        when Success
          read_result.map do |read|
            @mapper.read(read).map do |mapped|
              @source_accessor.set(source, mapped)
            end
          end
        when Failure
          if @optional
            JM::Success.new(source)
          else
            read_result
          end
        end
      end
    end
  end
end
