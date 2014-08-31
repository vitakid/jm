module JM
  module DSL
    # Configuration for {JM::DSL::Mapper#self_link}
    class SelfLinkConfiguration < Configuration
      # Define how to instantiate the object from the parsed URI parameters
      def read(&block)
        @read = block
      end

      # Define how to extract the URI template parameters from the object
      def write(&block)
        @write = block
      end

      # @api private
      def mapper(default)
        if @read || @write
          BlockMapper.new(@read, @write)
        elsif default
          default
        else
          raise Exception.new("You have to pass an accessor")
        end
      end
    end
  end
end
