module JM
  module DSL
    # A DSL for composing custom mappers
    #
    # You are supposed to subclass this class and configure your mapper with the
    # available configuration methods.
    class Mapper < JM::Mapper
      def initialize(source_class, target_class)
        @pipes = []
        @source_class = source_class
        @target_class = target_class
      end

      def pipe(pipe, read_only: false, write_if: nil, read_if: nil)
        if read_only
          pipe = Pipes::ReadOnlyPipe.new(pipe)
        end

        if write_if
          pipe = Pipes::ConditionalWritePipe.new(pipe, write_if)
        end

        if read_if
          pipe = Pipes::ConditionalReadPipe.new(pipe, read_if)
        end

        @pipes << pipe
      end

      def property(name,
                   accessor: Accessors::AccessorAccessor.new(name),
                   mapper: nil,
                   **rest,
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

        pipe(p, **rest)
      end

      def read_only_property(name, **args, &block)
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

      def array(name, mapper, **args)
        args[:mapper] = JM::Mappers::ArrayMapper.new(mapper)

        property(name, **args)
      end

      def write(object)
        target = instantiate_target(object)

        @pipes.each_with_object(target) do |pipe, t|
          pipe.pipe(object, t)
        end
      end

      def read(target)
        source = instantiate_source(target)

        @pipes.each_with_object(source) do |pipe, s|
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
