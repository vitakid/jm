module JM
  module DSL
    # Configuration for {Mapper#property}
    class PropertyConfiguration < Configuration
      # Define how to read the property
      def get(&block)
        @get = block
      end

      # Define how to write the property back
      def set(&block)
        @set = block
      end

      # Define how to convert the property value from right to left
      def read(&block)
        @read = block
      end

      # Define how to convert the property value from left to right
      def write(&block)
        @write = block
      end

      # @api private
      def accessor(given)
        if @get || @set
          BlockAccessor.new(@get, @set)
        elsif given
          given
        else
          raise JM::Exception.new("You have to pass an accessor")
        end
      end

      # @api private
      def mapper(given)
        if @read || @write
          BlockMapper.new(@read, @write)
        elsif given
          given
        else
          raise JM::Exception.new("You have to pass a mapper")
        end
      end
    end
  end
end
