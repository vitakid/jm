module JM
  module HAL
    # Access HAL links by rel in HAL hashes
    class LinkAccessor < Accessor
      LINKS_ACCESSOR = Accessors::HashKeyAccessor.new("_links", {})

      def initialize(rel)
        @rel_accessor = Accessors::HashKeyAccessor.new(rel.to_s)
      end

      def get(hash)
        hash["_links"] ||= {}

        LINKS_ACCESSOR.get(hash).map do |links|
          result = @rel_accessor.get(links)

          case result
          when Success then result
          when Failure then result.sink(["_links"])
          end
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
