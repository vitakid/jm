module JM
  module HAL
    # Access HAL links by rel in HAL hashes
    class LinkAccessor < Accessor
      def initialize(rel)
        @rel = rel
      end

      def get(hash)
        links = hash[:_links]

        if links
          links[@rel]
        end
      end

      def set(hash, link)
        hash[:_links] ||= {}

        hash[:_links][@rel] = link
      end
    end
  end
end
