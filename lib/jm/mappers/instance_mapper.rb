module JM
  module Mappers
    # A Mapper, that just returns empty objects of the source and target classes
    class InstanceMapper < Mapper
      def initialize(source_class, target_class)
        @source_class = source_class
        @target_class = target_class
      end

      def read(target)
        Success.new(@source_class.new)
      end

      def write(source)
        Success.new(@target_class.new)
      end
    end
  end
end
