module JM
  module HAL
    # Access HAL embedded resources by rel in HAL hashes
    class EmbeddedAccessor < Accessor
      EMBEDDED_ACCESSOR = Accessors::HashKeyAccessor.new("_embedded")

      def initialize(rel)
        @rel_accessor = Accessors::HashKeyAccessor.new(rel.to_s)
      end

      def get(hash)
        EMBEDDED_ACCESSOR.get(hash).map do |embedded|
          @rel_accessor.get(embedded)
        end
      end

      def set(hash, resource)
        hash["_embedded"] ||= {}

        @rel_accessor.set(hash["_embedded"], resource).map do
          Success.new(hash)
        end
      end
    end
  end
end
