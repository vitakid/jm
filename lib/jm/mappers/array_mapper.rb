module JM
  module Mappers
    # Map an item mapper over every item of an array
    class ArrayMapper < Mapper
      def initialize(item_mapper)
        @item_mapper = item_mapper
      end

      def read(array)
        array.map do |item|
          @item_mapper.read(item)
        end
      end

      def write(array)
        array.map do |item|
          @item_mapper.write(item)
        end
      end
    end
  end
end
