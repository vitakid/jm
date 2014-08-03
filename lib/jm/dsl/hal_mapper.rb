module JM
  module DSL
    class HALMapper < DSL::Mapper
      def self.link(rel, uri_template, &block)
        params_mapper_class = Class.new(JM::Mapper)
        params_mapper_class.class_exec(&block)
        params_mapper = params_mapper_class.new

        link_mapper = HAL::LinkMapper.new(uri_template, params_mapper)
        link_accessor = HAL::LinkAccessor.new(rel)
        accessor = Accessors::MappedAccessor.new(link_mapper, link_accessor)
        self.self_link_accessor = accessor
      end

      def self.self_link_accessor
        @self_link_accessor
      end

      def self.self_link_accessor=(accessor)
        @self_link_accessor = accessor
      end

      def self_link_accessor
        self.class.self_link_accessor
      end

      def instantiate_source(target)
        if self_link_accessor
          self_link_accessor.get(target)
        else
          super
        end
      end

      def instantiate_target(source)
        if self_link_accessor
          target = {}

          self_link_accessor.set(target, source)

          target
        else
          super
        end
      end
    end
  end
end
