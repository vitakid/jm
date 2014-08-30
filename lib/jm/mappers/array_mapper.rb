module JM
  module Mappers
    # Map an item mapper over every item of an array
    class ArrayMapper < Mapper
      REDUCER = Results::ArrayReducer.new

      def initialize(item_mapper)
        @item_mapper = item_mapper
      end

      def read(array)
        results = array.map do |item|
          @item_mapper.read(item)
        end

        REDUCER.reduce(results)
      end

      def write(array)
        results = array.map do |item|
          @item_mapper.write(item)
        end

        REDUCER.reduce(results)
      end
    end
  end
end
