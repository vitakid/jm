module JM
  module HAL
    # Access HAL links by rel in HAL hashes
    class LinkAccessor < Accessor
      LINK_ACCESSOR = Accessors::HashKeyAccessor.new("_links")

      def initialize(rel)
        @rel_accessor = Accessors::HashKeyAccessor.new(rel.to_s)
      end

      def get(hash)
        hash["_links"] ||= {}

        LINK_ACCESSOR.get(hash).map do |links|
          @rel_accessor.get(links)
        end
      end

      def set(hash, link)
        hash["_links"] ||= {}

        @rel_accessor.set(hash["_links"], link).map do
          Success.new(hash)
        end
      end
    end
  end
end
