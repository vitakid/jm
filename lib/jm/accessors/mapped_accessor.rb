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
        value = @accessor.get(object)

        @mapper.read(value)
      end

      def set(object, value)
        @accessor.set(object, @mapper.write(value))
      end
    end
  end
end
