module JM
  module DSL
    # A DSL for composing custom mappers
    #
    # You are supposed to subclass this class and configure your mapper with the
    # available configuration methods.
    class Mapper < JM::Mapper
      # Add an arbitrary mapper
      def self.mapper(mapper)
        @mappers ||= []

        @mappers << mapper
      end

      def self.property(name)
        mapper(JM::Mappers::PropertyMapper.new(name))
      end

      def self.mappers
        @mappers
      end

      def mappers
        self.class.mappers
      end

      def read(object)
        mappers.reduce({}) do |hash, mapper|
          mapper.read(object, hash)
        end
      end

      def write(object, data)
        mappers.reduce(object) do |obj, mapper|
          mapper.write(obj, data)
        end
      end
    end
  end
end
