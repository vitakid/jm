module JM
  module DSL
    # An extended DSL with specialized methods for mapping to HAL
    class HALMapper < DSL::Mapper
      # Initialize a new HAL mapper
      #
      # @param [Class] klass Class of the object to be mapped. When you try to
      #   {#read} a HAL resource without a "self" link, the mapper will
      #   instantiate a new object with `klass.new` instead of {#self_link}.
      def initialize(klass)
        instance_mapper = JM::Mappers::InstanceMapper.new(klass, Hash)
        link_mapper = JM::DSL::SelfLinkWrapper.new(self, instance_mapper)

        super(link_mapper)
      end

      # Map all properties to and from string names
      def property(name, *args, &block)
        super(name.to_s, *args, &block)
      end

      # Configure the mapping to the URI for the "self" link relation
      #
      # During {#read} this mapping will be used to instantiate the source
      # object before applying the pipes to it.
      #
      # @example
      #   self_link "/people/{name}" do
      #     read do |params|
      #       Person.new(params["name"])
      #     end
      #
      #     write do |person|
      #       { name: person.name }
      #     end
      #   end
      # @param [String] uri_template RFC6570 URI template
      # @param [JM::Mapper] params_mapper Map source object to and from
      #   template parameters
      # @param block Define params_mapper inline
      # @see SelfLinkConfiguration
      def self_link(uri_template, params_mapper: nil, &block)
        config = SelfLinkConfiguration.new(&block)
        params_mapper = config.mapper(params_mapper)
        link_mapper = HAL::LinkMapper.new(uri_template)
        mapper = Mappers::MapperChain.new([params_mapper, link_mapper])

        @self_link_mapper = mapper
      end

      # @api private
      def self_link_mapper
        @self_link_mapper
      end

      # Link to a resource
      #
      # This is a general frontend to define links, that refers to other methods
      # depending on it's arguments.
      #
      # @see #inline_link
      # @see #mapper_link
      def link(rel, template_or_mapper, **args, &block)
        if template_or_mapper.is_a?(String)
          inline_link(rel, template_or_mapper, **args, &block)
        else
          mapper_link(rel, template_or_mapper, **args, &block)
        end
      end

      # Link to a resource with an URI template
      #
      # @example
      #   inline_link :pet, "/people/{person}/pets/{name}" do
      #     get do |person|
      #       { person: person.name, name: person.pet.name }
      #     end
      #
      #     set do |person, params|
      #       person.pet = Pet.new(params["name"])
      #     end
      #   end
      # @param [Symbol] rel Link relation name
      # @param [String] uri_template RFC6570 URI template
      # @param [JM::Accessor] params_accessor Accessor to read template params
      #   from source and write them back
      # @param [Hash] args Passed on to {#pipe}
      # @param block Define the params_accessor inline
      # @see LinkConfiguration
      def inline_link(rel,
                      uri_template,
                      params_accessor:
                        TemplateParamsAccessor.new(uri_template),
                      **args,
                      &block)
        config = LinkConfiguration.new(&block)

        p_config = {
          source_accessor: config.accessor(params_accessor),
          mapper: HAL::LinkMapper.new(uri_template),
          target_accessor: HAL::LinkAccessor.new(rel)
        }

        p = Pipes::CompositePipe.new(p_config)

        pipe(p, **args)
      end

      # Link to a resource by reusing the "self" link of another mapper
      #
      # @param [Symbol] rel Link relation name
      # @param [JM::Mapper] mapper Mapper to reuse
      # @param [JM::Accessor] accessor Accessor for the object, that will be
      #   passed to the mapper
      # @param [Hash] args Passed on to {#pipe}
      # @param block Define the accessor inline
      # @see LinkConfiguration
      def mapper_link(rel,
                      mapper,
                      accessor:
                        Accessors::AccessorAccessor.new(rel),
                      **args,
                      &block)
        config = LinkConfiguration.new(&block)

        p_config = {
          source_accessor: config.accessor(accessor),
          mapper: mapper.self_link_mapper,
          target_accessor: HAL::LinkAccessor.new(rel)
        }

        p = Pipes::CompositePipe.new(p_config)

        pipe(p, **args)
      end

      # Link to an array of resources
      #
      # @param [Symbol] rel Link relation name
      # @param [JM::Mapper] mapper Mapper, that is applied to all array items
      # @param [JM::Accessor] accessor Accessor for the array
      # @param [Hash] args Passed on to {#pipe}
      # @param block Define the accessor inline
      # @see LinkConfiguration
      def links(rel, mapper, accessor: nil, **args, &block)
        config = LinkConfiguration.new(&block)

        p_config = {
          source_accessor: config.accessor(accessor),
          mapper: Mappers::ArrayMapper.new(mapper.self_link_mapper),
          target_accessor: HAL::LinkAccessor.new(rel)
        }

        p = Pipes::CompositePipe.new(p_config)

        pipe(p, **args)
      end

      # Embed a resource
      #
      # Embedded resources are read-only be default, so that you don't grant
      # access to objects accidentally.
      #
      # @param [Symbol] rel Link relation
      # @param [JM::Mapper] mapper Mapper for the object
      # @param [JM::Accessor] accessor Accessor for the object
      # @param [Hash] args Passed on to {#pipe}
      # @param block Define the accessor and/or mapper inline
      # @see EmbeddedConfiguration
      def embedded(rel,
                   mapper: nil,
                   accessor: Accessors::AccessorAccessor.new(rel),
                   read_only: true,
                   **args,
                   &block)
        config = EmbeddedConfiguration.new(&block)
        embedded_accessor = HAL::EmbeddedAccessor.new(rel)

        p_config = {
          source_accessor: config.accessor(accessor),
          mapper: config.get_mapper(mapper),
          target_accessor: embedded_accessor
        }

        p = Pipes::CompositePipe.new(p_config)

        args[:read_only] = read_only

        pipe(p, **args)
      end

      # Embed an array of resources
      #
      # Embedded resources are read-only be default, so that you don't grant
      # access to objects accidentally.
      #
      # @param [Symbol] rel Link relation
      # @param [JM::Mapper] mapper Mapper the array items
      # @param [JM::Accessor] accessor Accessor for the array
      # @param [Hash] args Passed on to {#pipe}
      # @param block Define the accessor and/or item mapper inline
      # @see EmbeddedConfiguration
      def embeddeds(rel,
                    mapper: nil,
                    accessor: Accessors::AccessorAccessor.new(rel),
                    read_only: true,
                    **args,
                    &block)
        config = EmbeddedConfiguration.new(&block)

        p_config = {
          source_accessor: config.accessor(accessor),
          mapper: Mappers::ArrayMapper.new(config.get_mapper(mapper)),
          target_accessor: HAL::EmbeddedAccessor.new(rel)
        }

        p = Pipes::CompositePipe.new(p_config)

        args[:read_only] = read_only

        pipe(p, **args)
      end
    end
  end
end
