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

      def get(object, *args)
        @accessor.get(object, *args).map do |value|
          @mapper.read(value, *args)
        end
      end

      def set(object, value, *args)
        @mapper.write(value, *args).map do |v|
          @accessor.set(object, v, *args)
        end
      end
    end
  end
end
