module JM
  module DSL
    # Builder for a "self" link mapper
    class SelfLinkBuilder < Builder
      def initialize(uri_template, mapper)
        @uri_template = uri_template
        @mapper = mapper
      end

      # Define how to instantiate the object from the parsed URI parameters
      def read(&block)
        @read = block
      end

      # Define how to extract the URI template parameters from the object
      def write(&block)
        @write = block
      end

      # Create a mapper from the settings
      def to_mapper
        if @read || @write
          mapper = BlockMapper.new(@read, @write)
        elsif @mapper
          mapper = @mapper
        else
          raise Exception.new("You have to pass a mapper")
        end

        link_mapper = HAL::LinkMapper.new(@uri_template)

        Mappers::MapperChain.new([mapper, link_mapper])
      end
    end
  end
end
