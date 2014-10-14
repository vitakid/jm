module JM
  module Mappers
    # Only apply the mapped wrapper, when there is a non-nil value
    class WhenValue < Mapper
      def initialize(mapper)
        @mapper = mapper
      end

      def read(value)
        if value.nil?
          JM::Success.new(nil)
        else
          @mapper.read(value)
        end
      end

      def write(value)
        if value.nil?
          JM::Success.new(nil)
        else
          @mapper.write(value)
        end
      end
    end
  end
end
