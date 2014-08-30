module JM
  module DSL
    # A DSL for composing custom mappers
    #
    # It is the base for all mappers. At it's heart is the {#pipe} method. It
    # let's you register a {JM::Pipe}. When writing an object, the object will
    # be {JM::Pipe#pipe}d through all pipes. And when reading an object, it will
    # be {JM::Pipe#slurp}ed through all pipes. So at this central point, you can
    # register custom pipes to take full control of the mapping process. Or you
    # could just use one of the DSL methods, that build a thin layer on top of
    # {#pipe}.
    #
    # You are supposed to subclass this class, configure your mapper with the
    # available configuration methods and extend the DSL to fit your mapping
    # processes.
    #
    # You should notice, that Mappers, in contrast to a lot of other ruby
    # libraries, are configured not with class methods but instance method calls
    # in the constructor. This gives you the possibility to parameterize the
    # configuration of the parent class without going to great lengths and doing
    # lots of ruby trickery. A simple example would be a parent class for all
    # mappers for HAL collection resources. In the derived classes you can
    # easily pass things like URI templates and page numbers via `#super`.
    class Mapper < JM::Mapper
      # Initialize a Mapper
      #
      # @param [JM::Mapper] factory A mapper, that instantiates a new target
      #   object on {JM::Mapper#write} and a new source object on
      #   {JM::Mapper#read}.
      def initialize(factory)
        @pipes = []
        @factory = factory
      end

      # Register a pipe
      #
      # This is the most general DSL method. Because pipes allow you to do
      # arbitrary mapping, this method gives you complete control and all other
      # methods are built on top of it. So methods like {#property} are actually
      # just shorthands for {#pipe} calls.
      #
      # Other methods should pass their keyword arguments to {#pipe}, so that
      # they can be configured to be read-only etc. All built-in methods follow
      # that principle.
      #
      # @param [JM::Pipe] pipe
      # @param [true, false] read_only Make the pipe read-only
      # @param [Proc] read_if It is passed the value to read.
      #   Only read, if the lambda evaluates to true
      # @param [Proc] write_if It is passed the value to write.
      #   Only write, if the lambda evaluates to true
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

      # Map a property
      #
      # @example Default mapping
      #   # Map source.name to hash[:name]
      #   property :name
      # @example Define an accessor inline
      #   property :name do
      #     def get(source)
      #       # Implement custom getting
      #       source.special_read_method
      #     end
      #
      #     def set(source, value)
      #       # Implement custom setting
      #       source.special_write_method(value)
      #     end
      #   end
      #
      # @param [Symbol] name Property to map
      # @param [JM::Accessor] accessor Customize, how the source is accessed
      # @param [JM::Mapper] mapper
      # @param [Hash] rest Other options are passed to {#pipe}
      # @param block Define an accessor inline
      def property(name,
                   accessor: Accessors::AccessorAccessor.new(name),
                   mapper: nil,
                   **rest,
                   &block)
        if block
          accessor = InlineAccessor.new(&block)
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

      # A shorthand to register read-only properties
      #
      # @example
      #   read_only_property :age do |source|
      #     Date.today - source.date_of_birth
      #   end
      # @param [Symbol] name Property to map
      # @param [Hash] args Passed on to {#property}
      # @param block Definition for {JM::Accessor#get}
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

      # Map an array property
      #
      # @example Map an array of dates to ISO8601 strings
      #   class ISOMapper < JM::Mapper
      #     def read(iso)
      #       Date.iso8601(iso)
      #     end
      #
      #     def write(date)
      #       date.iso8601
      #     end
      #   end
      #
      #   array :dates, ISOMapper.new
      # @param [Symbol] name Property to map
      # @param [JM::Mapper] mapper Mapper for individual array items
      # @param [Hash] args Passed on to {#property}
      # @param block Passed on to {#property}
      def array(name, mapper, **args, &block)
        args[:mapper] = JM::Mappers::ArrayMapper.new(mapper)

        property(name, **args, &block)
      end

      # Write by piping the source through all registered pipes
      def write(object)
        target = instantiate_target(object)

        @pipes.each_with_object(target) do |pipe, t|
          pipe.pipe(object, t)
        end
      end

      # Read by slurping the target through all registered pipes
      def read(target)
        source = instantiate_source(target)

        @pipes.each_with_object(source) do |pipe, s|
          pipe.slurp(s, target)
        end
      end

      # @api private
      def instantiate_source(target)
        @factory.read(target)
      end

      # @api private
      def instantiate_target(source)
        @factory.write(source)
      end
    end
  end
end
