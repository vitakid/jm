module JM
  module DSL
    # Use the {HALMapper#self_link_accessor} of another {HALMapper} to map to and
    # from links
    class SelfLinkWrapper < Mapper
      def initialize(mapper)
        @mapper = mapper
      end

      def write(object)
        link = @mapper.self_link_mapper.write(object)

        { _links: { self: link } }
      end

      def read(resource)
        link = resource.fetch(:_links, {}).fetch(:self)

        @mapper.self_link_mapper.read(link)
      end
    end
  end
end
