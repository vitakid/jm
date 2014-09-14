module JM
  module DSL
    # Builder for a property pipe
    class PropertyBuilder < Builder
      def initialize(name, accessor, validator, mapper, optional)
        @name = name
        @accessor = accessor
        @validator = validator
        @mapper = mapper
        @optional = optional
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

      # Create a property pipe from the configuration
      #
      # @return [JM::Pipe]
      def to_pipe
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
          target_accessor: Accessors::HashKeyAccessor.new(@name),
          optional: @optional
        }

        Pipes::CompositePipe.new(**args)
      end
    end
  end
end
