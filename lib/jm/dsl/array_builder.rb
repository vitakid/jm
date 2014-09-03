module JM
  module DSL
    # Builder for an array pipe
    class ArrayBuilder < Builder
      def initialize(name,
                     accessor,
                     element_mapper,
                     validator,
                     element_validator)
        @name = name
        @accessor = accessor
        @element_mapper = element_mapper
        @validator = validator
        @element_validator = element_validator
      end

      # Define how to read the array
      #
      # @example
      #   get do |object|
      #     object.value
      #   end
      def get(&block)
        @get = block
      end

      # Define how to write the array back
      #
      # @example
      #   set do |object, value|
      #     object.value = value
      #   end
      def set(&block)
        @set = block
      end

      # Define a validator for the array with the DSL
      #
      # @example
      #   validator do
      #     inline do |array|
      #       # Validate the array...
      #     end
      #   end
      def validator(&block)
        @validator = DSL::Validator.new
        @validator.instance_exec(&block)
      end

      # Define a validator for the array elements with the DSL
      #
      # @example
      #   element_validator do
      #     inline do |element|
      #       # Validate the array element...
      #     end
      #   end
      def element_validator(&block)
        @element_validator = DSL::Validator.new
        @element_validator.instance_exec(&block)
      end

      # Define a mapper for the array elements with the DSL
      #
      # @example
      #   mapper do
      #     property :id
      #   end
      def mapper(&block)
        @element_mapper = DSL::Mapper.new
        @element_mapper.instance_exec(&block)
      end

      # Create an array pipe from the configuration
      #
      # @return [JM::Pipe]
      def to_pipe
        args = {
          source_accessor: build_accessor,
          mapper: build_mapper,
          target_accessor: Accessors::HashKeyAccessor.new(@name)
        }

        Pipes::CompositePipe.new(**args)
      end

      private

      def build_accessor
        if @get || @set
          BlockAccessor.new(@get, @set)
        elsif @accessor
          @accessor
        else
          raise Exception.new("You have to define an accessor")
        end
      end

      def build_mapper
        if @element_validator
          mapper = Mappers::ValidatedMapper.new(
            @element_mapper,
            Validators::IdentityValidator.new,
            @element_validator
          )
        else
          mapper = @element_mapper
        end

        mapper = Mappers::ArrayMapper.new(mapper)

        if @validator
          mapper = Mappers::ValidatedMapper.new(
            mapper,
            Validators::IdentityValidator.new,
            @validator
          )
        end

        Mappers::SinkingMapper.new(mapper, [@name])
      end
    end
  end
end
