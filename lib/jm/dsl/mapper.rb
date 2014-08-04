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
        @pipes || []
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
        target = instantiate_target(object)

        pipes.each_with_object(target) do |pipe, t|
          pipe.pipe(object, t)
        end
      end

      def read(target)
        source = instantiate_source(target)

        pipes.each_with_object(source) do |pipe, s|
          pipe.unpipe(s, target)
        end
      end

      def instantiate_source(target)
        @source_class.new
      end

      def instantiate_target(source)
        @target_class.new
      end
    end
  end
end
