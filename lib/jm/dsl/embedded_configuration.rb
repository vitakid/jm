module JM
  module DSL
    # Configuration for {JM::DSL::Mapper#embedded} and
    # {JM::DSL::Mapper#embeddeds}
    class EmbeddedConfiguration < Configuration
      # Define how to read the value
      def get(&block)
        @get = block
      end

      # Define how to write the value
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

      # @api private
      def accessor(default)
        if @get || @set
          BlockAccessor.new(@get, @set)
        elsif default
          default
        else
          raise Exception.new("You have to pass an accessor")
        end
      end

      # @api private
      def get_mapper(default)
        if @mapper
          @mapper
        elsif default
          default
        else
          raise Exception.new("You have to pass a mapper")
        end
      end
    end
  end
end
