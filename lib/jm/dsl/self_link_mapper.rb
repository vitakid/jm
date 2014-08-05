module JM
  module DSL
    # Use the {HALMapper#self_link_pipe} of another {HALMapper} to map to and
    # from links
    class SelfLinkMapper < Mapper
      def initialize(mapper)
        @mapper = mapper
        @pipe = mapper.self_link_pipe
      end

      def write(object)
        @pipe.pipe(object, {})
      end

      def read(link)
        hal = { _links: { self: link } }
        real = @mapper.instantiate_source(hal)

        @pipe.unpipe(real, hal)

        real
      end
    end
  end
end
