module JM
  module DSL
    # Builder for an a syncer for embedding an array
    class EmbeddedsBuilder < EmbeddedBuilder
      def initialize(rel, accessor, mapper, **args)
        mapper = Mappers::ArrayMapper.new(mapper)

        super(rel, accessor, mapper, **args)
      end

      # Define an inline mapper for the embedded resources
      #
      # @example
      #   mapper do
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
    end
  end
end
