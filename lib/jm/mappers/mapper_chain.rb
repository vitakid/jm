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

      def read(target, options = {}, context = {})
        @chain.reverse.reduce(Success.new(target)) do |result, mapper|
          result.map do |value|
            mapper.read(value, options, context)
          end
        end
      end

      def write(source, options = {}, context = {})
        @chain.reduce(Success.new(source)) do |result, mapper|
          result.map do |value|
            mapper.write(value, options, context)
          end
        end
      end
    end
  end
end
