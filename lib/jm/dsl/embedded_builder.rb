module JM
  module DSL
    # Builder for pipes for embedding objects
    class EmbeddedBuilder < Builder
      def initialize(rel, accessor, mapper)
        @rel = rel
        @accessor = accessor
        @mapper = mapper
      end

      # Define how to read the value
      #
      # @example
      #   get do |object|
      #     object.value
      #   end
      def get(&block)
        @get = block
      end

      # Define how to write the value
      #
      # @example
      #   set do |object, value|
      #     object.value = value
      #   end
      def set(&block)
        @set = block
      end

      # Define an inline mapper for the embedded resource
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