module JM
  module DSL
    # Configuration for {JM::DSL::Mapper#link} and {JM::DSL::Mapper#links}
    class LinkConfiguration < Configuration
      # Define how to read the URI parameters from the object
      def get(&block)
        @get = block
      end

      # Define how to write parsed URI parameters back into the object
      def set(&block)
        @set = block
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
    end
  end
end
