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
    class Pipe < JM::Pipe
      def initialize
        @pipes = []
      end

      # Register a pipe
      #
      # This is the most general DSL method. Because pipes allow you to do
      # arbitrary mapping, this method gives you complete control and all other
      # methods are built on top of it. So methods like {#property} are actually
      # just shorthands for {#pipe} calls.
      #
      # Other methods should pass their keyword arguments to {#pipe}, so that
      # they can be configured to be write-only etc. All built-in methods follow
      # that principle.
      #
      # @param [JM::Pipe] pipe
      # @param [true, false] write_only Make the pipe write-only
      # @param [Proc] read_if It is passed the value to read.
      #   Only read, if the lambda evaluates to true
      # @param [Proc] write_if It is passed the value to write.
      #   Only write, if the lambda evaluates to true
      def pipe(pipe, write_only: false, write_if: nil, read_if: nil)
        if write_only
          pipe = Pipes::WriteOnlyPipe.new(pipe)
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
      #     get do |source|
      #       # Implement custom getting
      #       source.special_read_method
      #     end
      #
      #     set do |source, value|
      #       # Implement custom setting
      #       source.special_write_method(value)
      #     end
      #   end
      # @param [Symbol] name Property to map
      # @param [JM::Accessor] accessor Customize, how the source is accessed
      # @param [JM::Mapper] mapper Convert the value during mapping
      # @param [JM::Validator] validator Validate the value
      # @param [Bool] optional Is this property optional? Optional values are
      #   not validated, if they are absent when reading.
      # @param [Hash] args Other options are passed to {#pipe}
      # @param block Configure the {PropertyBuilder}
      # @see PropertyBuilder
      def property(name,
                   accessor: Accessors::AccessorAccessor.new(name),
                   mapper: Mappers::IdentityMapper.new,
                   validator: nil,
                   optional: false,
                   **args,
                   &block)
        builder = PropertyBuilder.new(
          name, accessor, validator, mapper, optional)
        builder.configure(&block)

        pipe(builder.to_pipe, **args)
      end

      # A shorthand to register write-only properties
      #
      # @example
      #   write_only_property :age do |source|
      #     Date.today - source.date_of_birth
      #   end
      # @param [Symbol] name Property to map
      # @param [Hash] args Passed on to {#property}
      # @param block Definition for {JM::Accessor#get}
      def write_only_property(name, **args, &block)
        accessor_class = Class.new(Accessor) do
          define_method(:get) do |object|
            Success.new(block.call(object))
          end
        end

        accessor = accessor_class.new

        args[:accessor] = accessor
        args[:write_only] = true

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
      #   array :dates, mapper: ISOMapper.new
      # @param [Symbol] name Property to map
      # @param [JM::Mapper] mapper Mapper for individual array items
      # @param [JM::Validator] validator Validate the whole array
      # @param [JM::Validator] element_validator Validate individual array
      #   elements
      # @param [Hash] args Passed on to {#pipe}
      # @param block Configure the {ArrayBuilder}
      # @see ArrayBuilder
      def array(name,
                accessor: Accessors::AccessorAccessor.new(name),
                mapper: Mappers::IdentityMapper.new,
                validator: nil,
                element_validator: nil,
                **args,
                &block)
        builder = ArrayBuilder.new(name,
                                   accessor,
                                   mapper,
                                   validator,
                                   element_validator)
        builder.configure(&block)

        pipe(builder.to_pipe, **args)
      end

      # Pump the `source` through all registered pipes into `target`
      def pump(source, target)
        obj, failure = @pipes.reduce([target, Failure.new]) do |(t, f), pipe|
          res = pipe.pump(source, t)

          case res
          when Success then [res.value, f]
          when Failure then [t, f + res]
          end
        end

        if failure.errors.length > 0
          failure
        else
          Success.new(obj)
        end
      end

      # Slurp the `target` through all registered pipes into `source`
      def suck(source, target)
        obj, failure = @pipes.reduce([source, Failure.new]) do |(s, f), pipe|
          res = pipe.suck(s, target)

          case res
          when Success then [res.value, f]
          when Failure then [s, f + res]
          end
        end

        if failure.errors.length > 0
          failure
        else
          Success.new(obj)
        end
      end
    end
  end
end
