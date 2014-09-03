module JM
  module DSL
    # Builder for link pipes
    class LinkBuilder < Builder
      def initialize(rel, accessor, mapper)
        @rel = rel
        @accessor = accessor
        @mapper = mapper
      end

      # Define how to read the URI parameters from the object
      def get(&block)
        @get = block
      end

      # Define how to write parsed URI parameters back into the object
      def set(&block)
        @set = block
      end

      # Create a link pipe from settings
      def to_pipe
        if @get || @set
          accessor = BlockAccessor.new(@get, @set)
        elsif @accessor
          accessor = @accessor
        else
          raise Exception.new("You have to pass an accessor")
        end

        config = {
          source_accessor: accessor,
          mapper: @mapper,
          target_accessor: HAL::LinkAccessor.new(@rel)
        }

        Pipes::CompositePipe.new(config)
      end
    end
  end
end
