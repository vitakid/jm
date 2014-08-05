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

      def self.property(name,
                        accessor: Accessors::AccessorAccessor.new(name),
                        read_only: false,
                        mapper: nil,
                        write_if: nil,
                        read_if: nil,
                        &block)
        if block
          accessor_class = Class.new(Accessor)
          accessor_class.class_eval(&block)
          accessor = accessor_class.new
        end

        args = {
          source_accessor: accessor,
          target_accessor: Accessors::HashKeyAccessor.new(name)
        }

        if mapper
          args[:mapper] = mapper
        end

        p = Pipes::CompositePipe.new(**args)

        if read_only
          p = Pipes::ReadOnlyPipe.new(p)
        end

        if write_if
          p = Pipes::ConditionalWritePipe.new(p, write_if)
        end

        if read_if
          p = Pipes::ConditionalReadPipe.new(p, read_if)
        end

        pipe(p)
      end

      def self.read_only_property(name, **args, &block)
        accessor_class = Class.new(Accessor) do
          define_method(:get) do |object|
            block.call(object)
          end
        end

        accessor = accessor_class.new

        args[:accessor] = accessor
        args[:read_only] = true

        property(name, **args)
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
