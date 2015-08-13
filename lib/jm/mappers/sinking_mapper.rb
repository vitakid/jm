module JM
  module Mappers
    # Sink the failures of a wrapped mapper to a given path
    #
    # @example Prepend a path to all failures
    #   SinkingMapper.new(SomeMapper.new, [:some, :path, 2])
    class SinkingMapper < Mapper
      def initialize(mapper, path)
        @mapper = mapper
        @path = path
      end

      def read(*args)
        result = @mapper.read(*args)

        case result
        when Success then result
        when Failure then result.sink(@path)
        end
      end

      def write(*args)
        result = @mapper.write(*args)

        case result
        when Success then result
        when Failure then result.sink(@path)
        end
      end
    end
  end
end
