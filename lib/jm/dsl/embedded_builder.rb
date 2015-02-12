module JM
  module DSL
    # Builder for syncers for embedding objects
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
      # @param block Block to configure the mapper
      def mapper(&block)
        syncer = HALSyncer.new
        syncer.instance_exec(&block)

        @mapper = syncer.to_mapper
      end

      def to_syncer
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

        Syncers::CompositeSyncer.new(config)
      end
    end
  end
end
