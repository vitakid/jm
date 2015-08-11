module JM
  module DSL
    # A DSL for composing custom syncers
    #
    # It is the base for all syncers. At it's heart is the {#syncer} method. It
    # let's you register a {JM::Syncer}. When synchronizing from an object, the
    # object's data will be {JM::Syncer#push}ed by the registered syncers into
    # the target. And when synchronizing back, the data will be
    # {JM::Syncer#pull}ed through by the same syncers back from the target into
    # the object.
    #
    # Most of the time you should use the predefined methods to configure your
    # syncer, for example {#property}. If however your requirements are more
    # complex than the authors of JM envisioned, you can always resort to
    # {#syncer} to take full control and implement arbitrary behaviour.
    #
    # You are supposed to subclass this class, configure your syncer with the
    # available configuration methods and extend the DSL to fit your mapping
    # processes.
    #
    # You should notice, that syncers, in contrast to a lot of other ruby
    # libraries, are configured not with class methods but instance method calls
    # in the constructor. This gives you the possibility to parameterize the
    # configuration of the parent class without going to great lengths and doing
    # lots of ruby trickery. A simple example would be a parent class for
    # syncers of HAL collection resources. In the derived classes you can easily
    # pass things like URI templates and page numbers via `#super`.
    class Syncer < JM::Syncer
      def initialize
        @syncers = []
      end

      # Register a syncer
      #
      # This is the most general DSL method. Because syncers allow you to do
      # arbitrary mapping, this method gives you complete control and all other
      # methods are built on top of it. So methods like {#property} are actually
      # just shorthands for {#syncer} calls.
      #
      # Other methods should pass their keyword arguments to {#syncer}, so that
      # they can be configured to be write-only etc. All built-in methods follow
      # that principle.
      #
      # @param [JM::Syncer] syncer
      # @param [true, false] write_only Make the syncer write-only
      # @param [Proc] read_if It is passed the value to read.
      #   Only read, if the lambda evaluates to true
      # @param [Proc] write_if It is passed the value to write.
      #   Only write, if the lambda evaluates to true
      def syncer(syncer, write_only: false, write_if: nil, read_if: nil)
        if write_only
          syncer = Syncers::WriteOnlySyncer.new(syncer)
        end

        if write_if
          syncer = Syncers::ConditionalWriteSyncer.new(syncer, write_if)
        end

        if read_if
          syncer = Syncers::ConditionalReadSyncer.new(syncer, read_if)
        end

        @syncers << syncer
      end

      # Synchronize a property
      #
      # @example Default synchronization
      #   # Synchronize source.name with hash[:name]
      #   property :name
      # @example Define a source accessor inline
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
      # @param [Symbol] name Property to synchronize
      # @param [JM::Accessor] accessor Customize, how the source is accessed
      # @param [JM::Mapper] mapper Convert the value during synchronization
      # @param [JM::Validator] validator Validate the value
      # @param [Hash] args Other options are passed to {#syncer}
      # @param block Configure the {PropertyBuilder}
      # @see PropertyBuilder
      def property(name,
                   accessor: Accessors::AccessorAccessor.new(name),
                   mapper: Mappers::IdentityMapper.new,
                   validator: nil,
                   **args,
                   &block)
        builder = PropertyBuilder.new(name, accessor, validator, mapper)
        builder.configure(&block)

        syncer(builder.to_syncer, **args)
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

      # Synchronize an array property
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
      # @param [Symbol] name Property to synchronize
      # @param [JM::Mapper] mapper Mapper for individual array items
      # @param [JM::Validator] validator Validate the whole array
      # @param [JM::Validator] element_validator Validate individual array
      #   elements
      # @param [Hash] args Passed on to {#syncer}
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

        syncer(builder.to_syncer, **args)
      end

      # Push the `source` through all registered syncers into `target`
      def push(source, target)
        init = [target, Failure.new]
        obj, failure = @syncers.reduce(init) do |(t, f), syncer|
          res = syncer.push(source, t)

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

      # Pull the `target` through all registered syncers into `source`
      def pull(source, target)
        init = [source, Failure.new]
        obj, failure = @syncers.reduce(init) do |(s, f), syncer|
          res = syncer.pull(s, target)

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
