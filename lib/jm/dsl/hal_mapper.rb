module JM
  module DSL
    # Extended DSL for HAL mapping
    class HALMapper < DSL::Mapper
      def initialize(klass)
        instance_mapper = JM::Mappers::InstanceMapper.new(klass, Hash)
        link_mapper = JM::DSL::SelfLinkWrapper.new(self, instance_mapper)

        super(link_mapper)
      end

      def property(name, *args, &block)
        super(name.to_s, *args, &block)
      end

      def self_link(uri_template, params_mapper: nil, &block)
        params_mapper = mapper_or_die(params_mapper, &block)
        link_mapper = HAL::LinkMapper.new(uri_template)
        mapper = Mappers::MapperChain.new([params_mapper, link_mapper])

        @self_link_mapper = mapper
      end

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

      def block_to_accessor(&block)
        accessor_class = Class.new(JM::Accessor)
        accessor_class.class_exec(&block)

        accessor_class.new
      end

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

      def block_to_mapper(&block)
        accessor_class = Class.new(JM::Mapper)
        accessor_class.class_exec(&block)

        accessor_class.new
      end
    end
  end
end
