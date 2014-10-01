module JM
  module DSL
    # Use the {HALPipe#link_mapper} of another {HALPipe} to map to and from
    # links
    #
    # If the pipe has no self link or no self link is present, fall back to
    # fallback pipe.
    class SelfLinkWrapper < Mapper
      def initialize(pipe, fallback)
        @pipe = pipe
        @fallback = fallback
      end

      def write(object)
        if @pipe.link_mapper
          result = @pipe.link_mapper.write(object)

          result.map do |link|
            Success.new("_links" => { "self" => link })
          end
        else
          @fallback.write(object)
        end
      end

      def read(resource)
        link = resource.fetch("_links", {}).fetch("self", nil)

        if link && @pipe.link_mapper
          @pipe.link_mapper.read(link)
        else
          @fallback.read(resource)
        end
      end
    end
  end
end
