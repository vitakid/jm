module JM
  module DSL
    # A DSL for composing custom mappers
    #
    # You are supposed to subclass this class and configure your mapper with the
    # available configuration methods.
    class Mapper < JM::Mapper
      def self.pipe(pipe)
        @pipes ||= []

        @pipes << pipe
      end

      def self.pipes
        @pipes
      end

      def self.property(name, **args)
        args[:source_accessor] ||= Accessors::AccessorAccessor.new(name)
        args[:target_accessor] ||= Accessors::HashKeyAccessor.new(name)

        p = JM::Pipes::CompositePipe.new(**args)

        pipe(p)
      end

      def self.array(name, mapper)
        property(name, mapper: JM::Mappers::ArrayMapper.new(mapper))
      end

      def initialize(source_class, target_class)
        @source_class = source_class
        @target_class = target_class
      end

      def pipes
        self.class.pipes
      end

      def write(object)
        pipes.each_with_object(instantiate_target) do |pipe, hash|
          pipe.pipe(object, hash)
        end
      end

      def read(hash)
        pipes.each_with_object(instantiate_source) do |pipe, obj|
          pipe.unpipe(obj, hash)
        end
      end

      def instantiate_source
        @source_class.new
      end

      def instantiate_target
        @target_class.new
      end
    end
  end
end
