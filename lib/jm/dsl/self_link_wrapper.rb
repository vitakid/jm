module JM
  module DSL
    # Use the {HALMapper#self_link_mapper} of another {HALMapper} to map to and
    # from links
    #
    # If the mapper has no self link or no self link is present, fall back to
    # fallback mapper.
    class SelfLinkWrapper < Mapper
      def initialize(mapper, fallback)
        @mapper = mapper
        @fallback = fallback
      end

      def write(object)
        if @mapper.self_link_mapper
          result = @mapper.self_link_mapper.write(object)

          result.map do |link|
            Success.new("_links" => { "self" => link })
          end
        else
          @fallback.write(object)
        end
      end

      def read(resource)
        link = resource.fetch("_links", {}).fetch("self", nil)

        if link && @mapper.self_link_mapper
          @mapper.self_link_mapper.read(link)
        else
          @fallback.read(resource)
        end
      end
    end
  end
end
