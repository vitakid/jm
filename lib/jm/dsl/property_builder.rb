module JM
  module DSL
    # Builder for a property syncer
    class PropertyBuilder < Builder
      def initialize(name, accessor, validator, mapper)
        @name = name
        @accessor = accessor
        @validator = validator
        @mapper = mapper
      end

      # Define how to read the property
      #
      # @example
      #   get do |object|
      #     object.value
      #   end
      def get(&block)
        @get = block
      end

      # Define how to write the property
      #
      # @example
      #   set do |object, value|
      #     object.value = value
      #   end
      def set(&block)
        @set = block
      end

      # Define a mapper for the property with the DSL
      #
      # @example
      #   mapper do
      #     property :id
      #   end
      def mapper(&block)
        @mapper = DSL::Mapper.new
        @mapper.instance_exec(&block)
      end

      # Define a validator for the property with the DSL
      #
      # @example
      #   validator do
      #     inline do |value|
      #       # Validate value...
      #     end
      #   end
      def validator(&block)
        @validator = DSL::Validator.new
        @validator.instance_exec(&block)
      end

      # Create a property syncer from the configuration
      #
      # @return [JM::Syncer]
      def to_syncer
        if @get || @set
          accessor = BlockAccessor.new(@get, @set)
        elsif @accessor
          accessor =  @accessor
        else
          raise Exception.new("You have to define an accessor")
        end

        if @validator
          mapper = Mappers::ValidatedMapper.new(
            @mapper,
            Validators::IdentityValidator.new,
            @validator
          )
        else
          mapper = @mapper
        end

        mapper = Mappers::SinkingMapper.new(mapper, [@name])

        args = {
          source_accessor: accessor,
          mapper: mapper,
          target_accessor: Accessors::HashKeyAccessor.new(@name)
        }

        Syncers::CompositeSyncer.new(**args)
      end
    end
  end
end
