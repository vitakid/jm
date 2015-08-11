module JM
  module DSL
    # Builder for an a syncer for embedding an array
    class EmbeddedsBuilder < SyncerBuilder
      def initialize(rel, accessor, mapper, **args)
        super(**args)

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
      # @param block Block to configure the mapper
      def mapper(&block)
        syncer = HALSyncer.new
        syncer.instance_exec(&block)

        mapper = syncer.to_mapper

        @mapper = Mappers::ArrayMapper.new(mapper)
      end

      def create_syncer
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
