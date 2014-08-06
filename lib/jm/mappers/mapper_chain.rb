module JM
  module Mappers
    # Build a chain of mappers, in which each maps the result of the previous
    #
    # So when reading, data flows
    #
    #   => mapper-1 => mapper-2 => ... => mapper-n =>
    #
    # and when writing, it flows
    #
    #   <= mapper-1 <= mapper-2 <= ... <= mapper-n <=
    class MapperChain < Mapper
      def initialize(mappers)
        @chain = mappers
      end

      def read(target)
        @chain.reverse.reduce(target) do |acc, mapper|
          mapper.read(acc)
        end
      end

      def write(source)
        @chain.reduce(source) do |acc, mapper|
          mapper.write(acc)
        end
      end
    end
  end
end
