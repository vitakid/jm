module JM
  module DSL
    class SelfLinkProxyAccessor < Accessor
      def initialize(mapper, accessor, rel)
        @mapper = mapper
        @accessor = accessor
        @rel = rel
        @pipe = mapper.class.self_link_pipe
      end

      def set(object, link)
        hal = { _links: { self: link }}
        real = @mapper.instantiate_source(hal)

        @pipe.unpipe(real, hal);

        @accessor.set(object, real)
      end

      def get(object)
        real = @accessor.get(object)
        @pipe.pipe(real, {})
      end
    end
  end
end
