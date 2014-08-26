module JM
  module DSL
    # An extended DSL with specialized methods for mapping to HAL
    class HALMapper < DSL::Mapper
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
      #     def read(params)
      #       Person.new(params["name"])
      #     end
      #
      #     def write(person)
      #       { name: person.name }
      #     end
      #   end
      # @param [String] uri_template RFC6570 URI template
      # @param [JM::Mapper] params_mapper Map source object to and from
      #   template parameters
      # @param block Define params_mapper inline
      def self_link(uri_template, params_mapper: nil, &block)
        params_mapper = mapper_or_die(params_mapper, &block)
        link_mapper = HAL::LinkMapper.new(uri_template)
        mapper = Mappers::MapperChain.new([params_mapper, link_mapper])

        @self_link_mapper = mapper
      end

      # @api private
      def self_link_mapper
        @self_link_mapper
      end

      def link(rel, template_or_mapper, **args, &block)
        if template_or_mapper.is_a?(String)
          inline_link(rel, template_or_mapper, **args, &block)
        else
          mapper_link(rel, template_or_mapper, **args, &block)
        end
      end

      def inline_link(rel,
                      uri_template,
                      params_accessor:
                        TemplateParamsAccessor.new(uri_template),
                      **args,
                      &block)
        params_accessor = accessor_or_die(params_accessor, &block)

        link_mapper = HAL::LinkMapper.new(uri_template)
        link_accessor = HAL::LinkAccessor.new(rel)

        p = Pipes::CompositePipe.new(source_accessor: params_accessor,
                                     mapper: link_mapper,
                                     target_accessor: link_accessor)

        pipe(p, **args)
      end

      def mapper_link(rel,
                      mapper,
                      accessor:
                        Accessors::AccessorAccessor.new(rel),
                      **args,
                      &block)
        accessor = accessor_or_die(accessor, &block)
        link_accessor = HAL::LinkAccessor.new(rel)

        p = Pipes::CompositePipe.new(source_accessor: accessor,
                                     mapper: mapper.self_link_mapper,
                                     target_accessor: link_accessor)

        pipe(p, **args)
      end

      def links(rel, mapper, accessor: nil, **args, &block)
        accessor = accessor_or_die(accessor, &block)
        mapper = Mappers::ArrayMapper.new(mapper.self_link_mapper)
        link_accessor = HAL::LinkAccessor.new(rel)

        p = Pipes::CompositePipe.new(source_accessor: accessor,
                                     mapper: mapper,
                                     target_accessor: link_accessor)

        pipe(p, **args)
      end

      def embedded(rel,
                   mapper,
                   accessor: Accessors::AccessorAccessor.new(rel),
                   read_only: true,
                   **args,
                   &block)
        accessor = accessor_or_die(accessor, &block)
        embedded_accessor = HAL::EmbeddedAccessor.new(rel)

        p = Pipes::CompositePipe.new(source_accessor: accessor,
                                     mapper: mapper,
                                     target_accessor: embedded_accessor)

        args[:read_only] = read_only

        pipe(p, **args)
      end

      def embeddeds(rel,
                    mapper,
                    accessor: Accessors::AccessorAccessor.new(rel),
                    read_only: true,
                    **args,
                    &block)
        accessor = accessor_or_die(accessor, &block)
        mapper = Mappers::ArrayMapper.new(mapper)
        embedded_accessor = HAL::EmbeddedAccessor.new(rel)

        p = Pipes::CompositePipe.new(source_accessor: accessor,
                                     mapper: mapper,
                                     target_accessor: embedded_accessor)

        args[:read_only] = read_only

        pipe(p, **args)
      end

      # @api private
      def accessor_or_die(accessor, &block)
        if block
          block_to_accessor(&block)
        else
          if accessor.nil?
            raise JM::Exception.new("You have to supply some form of accessor")
          else
            accessor
          end
        end
      end

      # @api private
      def block_to_accessor(&block)
        accessor_class = Class.new(JM::Accessor)
        accessor_class.class_exec(&block)

        accessor_class.new
      end

      # @api private
      def mapper_or_die(mapper, &block)
        if block
          block_to_mapper(&block)
        else
          if mapper.nil?
            raise JM::Exception.new("You have to supply some form of mapper")
          else
            mapper
          end
        end
      end

      # @api private
      def block_to_mapper(&block)
        accessor_class = Class.new(JM::Mapper)
        accessor_class.class_exec(&block)

        accessor_class.new
      end
    end
  end
end
