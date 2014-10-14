module JM
  module DSL
    # An extended DSL with specialized methods for mapping to HAL
    class HALPipe < DSL::Pipe
      def initialize
        super

        self.right_factory = Factories::NewFactory.new(Hash)
      end

      # Map all properties to and from string names
      def property(name, *args, &block)
        super(name.to_s, *args, &block)
      end

      # Map array properties to and from string names
      def array(name, *args, &block)
        super(name.to_s, *args, &block)
      end

      # Configure the mapping to the URI for the "self" link relation
      #
      # The `read` block defines, how to map the parsed URI parameters to an
      # object, while the `write` block defines, how to extract the URI
      # parameters.
      #
      # Notice, that the `read` block is not used, when {#suck}ing data in. If
      # you want to instantiate the object from the `self` link, you will have
      # to do it yourself with `pipe.link_mapper.read(<self link>)` and the pass
      # that object to {#suck}. The reason for this is, that the general use
      # case for jm is assumed to be web APIs. So when you are receiving a PUT
      # request to update some object, the object is determined by the request
      # URI. If the actually instantiated object was determined by some URI in
      # the request body, a user could update any object, even if he was only
      # allowed access to a specific one, and so bypass your authorization.
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
      # @param [JM::Mapper] mapper Map source object to and from
      #   template parameters
      # @param block Define mapper inline
      # @see SelfLinkBuilder
      def self_link(uri_template, mapper: nil, &block)
        builder = SelfLinkBuilder.new(uri_template, mapper)
        builder.configure(&block)

        @link_mapper = builder.to_mapper
        self_accessor = HAL::LinkAccessor.new("self")
        @link_accessor = Accessors::MappedAccessor.new(@link_mapper,
                                                       self_accessor)
      end

      # @api private
      def link_mapper
        @link_mapper
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
      # @see LinkBuilder
      def inline_link(rel,
                      uri_template,
                      params_accessor:
                        TemplateParamsAccessor.new(uri_template),
                      **args,
                      &block)
        builder = LinkBuilder.new(rel,
                                  params_accessor,
                                  HAL::LinkMapper.new(uri_template))
        builder.configure(&block)

        pipe(builder.to_pipe, **args)
      end

      # Link to a resource by reusing the "self" link of another mapper
      #
      # @param [Symbol] rel Link relation name
      # @param [JM::Mapper] mapper Mapper to reuse
      # @param [JM::Accessor] accessor Accessor for the object, that will be
      #   passed to the mapper
      # @param [Hash] args Passed on to {#pipe}
      # @param block Define the accessor inline
      # @see LinkBuilder
      def mapper_link(rel,
                      mapper,
                      accessor:
                        Accessors::AccessorAccessor.new(rel),
                      **args,
                      &block)
        builder = LinkBuilder.new(rel, accessor, mapper.link_mapper)
        builder.configure(&block)

        pipe(builder.to_pipe, **args)
      end

      # Link to an array of resources
      #
      # @param [Symbol] rel Link relation name
      # @param [JM::DSL::HALMapper] mapper Mapper, that is applied to all array
      #   items
      # @param [JM::Accessor] accessor Accessor for the array
      # @param [Hash] args Passed on to {#pipe}
      # @param block Define the accessor inline
      # @see LinkBuilder
      def links(rel, mapper, accessor: nil, **args, &block)
        builder = LinkBuilder.new(rel,
                                  accessor,
                                  Mappers::ArrayMapper.new(
                                    mapper.link_mapper),
                                  [])
        builder.configure(&block)

        pipe(builder.to_pipe, **args)
      end

      # Embed a resource
      #
      # Embedded resources are write-only be default, so that you don't grant
      # access to objects accidentally.
      #
      # @param [Symbol] rel Link relation
      # @param [JM::Mapper] mapper Mapper for the object
      # @param [JM::Accessor] accessor Accessor for the object
      # @param [Hash] args Passed on to {#pipe}
      # @param block Define the accessor and/or mapper inline
      # @see EmbeddedBuilder
      def embedded(rel,
                   mapper: nil,
                   accessor: Accessors::AccessorAccessor.new(rel),
                   write_only: true,
                   **args,
                   &block)
        builder = EmbeddedBuilder.new(rel, accessor, mapper)
        builder.configure(&block)

        pipe(builder.to_pipe, write_only: write_only, **args)
      end

      # Embed an array of resources
      #
      # Embedded resources are write-only be default, so that you don't grant
      # access to objects accidentally.
      #
      # @param [Symbol] rel Link relation
      # @param [JM::Mapper] mapper Mapper the array items
      # @param [JM::Accessor] accessor Accessor for the array
      # @param [Hash] args Passed on to {#pipe}
      # @param block Define the accessor and/or item mapper inline
      # @see EmbeddedBuilder
      def embeddeds(rel,
                    mapper: nil,
                    accessor: Accessors::AccessorAccessor.new(rel),
                    write_only: true,
                    **args,
                    &block)
        builder = EmbeddedsBuilder.new(rel,
                                       accessor,
                                       Mappers::ArrayMapper.new(mapper))
        builder.configure(&block)

        pipe(builder.to_pipe, write_only: write_only, **args)
      end

      def pump(source, target)
        result = super(source, target)

        if @link_accessor
          result.map do |object|
            @link_accessor.set(object, source)
          end
        else
          result
        end
      end
    end
  end
end
