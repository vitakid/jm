module JM
  module Accessors
    # Slots a mapper in ahead of an accessor
    #
    # Values are going through the mapper after getting and before setting.
    class MappedAccessor < Accessor
      def initialize(mapper, accessor)
        @mapper = mapper
        @accessor = accessor
      end

      def get(object)
        @accessor.get(object).map do |value|
          @mapper.read(value)
        end
      end

      def set(object, value)
        @mapper.write(value).map do |v|
          @accessor.set(object, v)
        end
      end
    end
  end
end
