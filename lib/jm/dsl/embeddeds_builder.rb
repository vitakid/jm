module JM
  module DSL
    # Builder for an a pipe for embedding an array
    class EmbeddedsBuilder < Builder
      def initialize(rel, accessor, mapper)
        @rel = rel
        @accessor = accessor
        @mapper = mapper
      end

      # Define how to read the array
      #
      # @example
      #   get do |object|
      #     object.array
      #   end
      def get(&block)
        @get = block
      end

      # Define how to write the array
      #
      # @example
      #   set do |object, array|
      #     object.array = array
      #   end
      def set(&block)
        @set = block
      end

      # Define an inline mapper for the embedded resources
      #
      # @example
      #   mapper(Person) do
      #     property :name
      #     property :age
      #   end
      # @param [Class] klass Class of the object to map (passed to
      #   {HALMapper#initialize})
      # @param block Block to configure the mapper
      def mapper(klass, &block)
        @mapper = HALMapper.new(klass)
        @mapper.instance_exec(&block)

        @mapper = Mappers::ArrayMapper.new(@mapper)
      end

      def to_pipe
        if @get || @set
          accessor = BlockAccessor.new(@get, @set)
        elsif @accessor
          accessor = @accessor
        else
          raise Exception.new("You have to pass an accessor")
        end

        if !@mapper
          raise Exception.new("You have to pass a mapper")
        end

        config = {
          source_accessor: accessor,
          mapper: @mapper,
          target_accessor: HAL::EmbeddedAccessor.new(@rel)
        }

        Pipes::CompositePipe.new(config)
      end
    end
  end
end
