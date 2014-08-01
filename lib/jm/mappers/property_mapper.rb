module JM
  module Mappers
    class PropertyMapper < Mapper
      def initialize(name)
        @name = name
      end

      def read(object, data)
        data[@name] = object.send(@name)

        data
      end

      def write(object, data)
        object.send(setter, data[@name])

        object
      end

      private

      def setter
        @setter ||= "#{@name}=".to_sym
      end
    end
  end
end
