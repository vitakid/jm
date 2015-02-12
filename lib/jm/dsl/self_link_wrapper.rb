module JM
  module DSL
    # Use the {HALSyncer#link_mapper} of another {HALSyncer} to map to and from
    # links
    #
    # If the syncer has no self link or no self link is present, fall back to
    # fallback syncer.
    class SelfLinkWrapper < Mapper
      def initialize(syncer, fallback)
        @syncer = syncer
        @fallback = fallback
      end

      def write(object)
        if @syncer.link_mapper
          result = @syncer.link_mapper.write(object)

          result.map do |link|
            Success.new("_links" => { "self" => link })
          end
        else
          @fallback.write(object)
        end
      end

      def read(resource)
        link = resource.fetch("_links", {}).fetch("self", nil)

        if link && @syncer.link_mapper
          @syncer.link_mapper.read(link)
        else
          @fallback.read(resource)
        end
      end
    end
  end
end
