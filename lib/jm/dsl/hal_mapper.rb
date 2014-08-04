module JM
  module DSL
    class HALMapper < DSL::Mapper
      def self.inline_link(rel, uri_template, &block)
        params_accessor = block_to_accessor(&block)
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

      def self.link(rel, mapper, accessor: nil, &block)
        if accessor.nil?
          accessor = block_to_accessor(&block)
        end

        proxy_accessor = SelfLinkProxyAccessor.new(mapper, accessor, rel)
        link_accessor = HAL::LinkAccessor.new(rel)

        p = Pipes::CompositePipe.new(source_accessor: proxy_accessor,
                                     target_accessor: link_accessor)

        pipe(p)
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
