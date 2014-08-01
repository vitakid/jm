module JM
  module DSL
    class Mapper < JM::Mapper
      def self.property(name)
        @mappers ||= []

        @mappers << JM::Mappers::PropertyMapper.new(name)
      end

      def mappers
        self.class.instance_variable_get(:@mappers)
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
