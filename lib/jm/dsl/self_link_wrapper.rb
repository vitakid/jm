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

      def write(*args)
        if @syncer.link_mapper
          result = @syncer.link_mapper.write(*args)

          result.map do |link|
            Success.new("_links" => { "self" => link })
          end
        else
          @fallback.write(*args)
        end
      end

      def read(resource, *args)
        link = resource.fetch("_links", {}).fetch("self", nil)

        if link && @syncer.link_mapper
          @syncer.link_mapper.read(link, *args)
        else
          @fallback.read(resource, *args)
        end
      end
    end
  end
end
