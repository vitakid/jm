module JM
  module Mappers
    # Only apply the mapped wrapper, when there is a non-nil value
    class WhenValue < Mapper
      def initialize(mapper)
        @mapper = mapper
      end

      def read(value, options = {}, context = {})
        if value.nil?
          JM::Success.new(nil)
        else
          @mapper.read(value, options, context)
        end
      end

      def write(value, options = {}, context = {})
        if value.nil?
          JM::Success.new(nil)
        else
          @mapper.write(value, options, context)
        end
      end
    end
  end
end
