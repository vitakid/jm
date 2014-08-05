module JM
  module DSL
    # Extended DSL for HAL mapping
    class HALMapper < DSL::Mapper
      def self.link(rel, template_or_mapper, **args, &block)
        if template_or_mapper.is_a?(String)
          inline_link(rel, template_or_mapper, **args, &block)
        else
          mapper_link(rel, template_or_mapper, **args, &block)
        end
      end

      def self.inline_link(rel,
                           uri_template,
                           params_accessor:
                             TemplateParamsAccessor.new(uri_template),
                           &block)
        params_accessor = accessor_or_die(params_accessor, &block)

        link_mapper = HAL::LinkMapper.new(uri_template)
        link_accessor = HAL::LinkAccessor.new(rel)

        p = Pipes::CompositePipe.new(source_accessor: params_accessor,
                                     mapper: link_mapper,
                                     target_accessor: link_accessor)

        if rel == :self
          self.self_link_pipe = p
        else
          pipe(p)
        end
      end

      def self.mapper_link(rel, mapper, accessor: nil, &block)
        accessor = accessor_or_die(accessor, &block)
        mapper = SelfLinkMapper.new(mapper)
        link_accessor = HAL::LinkAccessor.new(rel)

        p = Pipes::CompositePipe.new(source_accessor: accessor,
                                     mapper: mapper,
                                     target_accessor: link_accessor)

        pipe(p)
      end

      def self.links(rel, mapper, accessor: nil, &block)
        accessor = accessor_or_die(accessor, &block)
        mapper = Mappers::ArrayMapper.new(SelfLinkMapper.new(mapper))
        link_accessor = HAL::LinkAccessor.new(rel)

        p = Pipes::CompositePipe.new(source_accessor: accessor,
                                     mapper: mapper,
                                     target_accessor: link_accessor)

        pipe(p)
      end

      def self.embedded(rel,
                        mapper,
                        accessor: Accessors::AccessorAccessor.new(rel),
                        &block)
        accessor = accessor_or_die(accessor, &block)
        embedded_accessor = HAL::EmbeddedAccessor.new(rel)

        p = Pipes::CompositePipe.new(source_accessor: accessor,
                                     mapper: mapper,
                                     target_accessor: embedded_accessor)

        pipe(p)
      end

      def self.embeddeds(rel,
                         mapper,
                         accessor: Accessors::AccessorAccessor.new(rel),
                         &block)
        accessor = accessor_or_die(accessor, &block)
        mapper = Mappers::ArrayMapper.new(mapper)
        embedded_accessor = HAL::EmbeddedAccessor.new(rel)

        p = Pipes::CompositePipe.new(source_accessor: accessor,
                                     mapper: mapper,
                                     target_accessor: embedded_accessor)

        pipe(p)
      end

      def self.accessor_or_die(accessor, &block)
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

      def self.block_to_accessor(&block)
        accessor_class = Class.new(JM::Accessor)
        accessor_class.class_exec(&block)

        accessor_class.new
      end

      def self.self_link_pipe
        @self_link_pipe
      end

      def self.self_link_pipe=(pipe)
        @self_link_pipe = pipe
      end

      def initialize(source_class)
        super(source_class, Hash)
      end

      def self_link_pipe
        self.class.self_link_pipe
      end

      def instantiate_source(target)
        source = super

        if self_link_pipe
          self_link_pipe.unpipe(source, target)
        end

        source
      end

      def instantiate_target(source)
        target = super

        if self_link_pipe
          self_link_pipe.pipe(source, target)
        end

        target
      end
    end
  end
end
