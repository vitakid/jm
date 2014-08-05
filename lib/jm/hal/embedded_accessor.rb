module JM
  module HAL
    # Access HAL embedded resources by rel in HAL hashes
    class EmbeddedAccessor < Accessor
      def initialize(rel)
        @rel = rel
      end

      def get(hash)
        embeddeds = hash[:_embedded]

        if embeddeds
          embeddeds[@rel]
        end
      end

      def set(hash, resource)
        hash[:_embedded] ||= {}

        hash[:_embedded][@rel] = resource
      end
    end
  end
end
