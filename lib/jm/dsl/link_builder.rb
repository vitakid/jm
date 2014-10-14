module JM
  module DSL
    # Builder for link pipes
    class LinkBuilder < Builder
      def initialize(rel, accessor, mapper, default_value = nil)
        @rel = rel
        @accessor = accessor
        @mapper = mapper
        @default_value = default_value
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

        @mapper = Mappers::WhenValue.new(@mapper)

        config = {
          source_accessor: accessor,
          mapper: @mapper,
          target_accessor: HAL::LinkAccessor.new(@rel, @default_value)
        }

        Pipes::CompositePipe.new(config)
      end
    end
  end
end
