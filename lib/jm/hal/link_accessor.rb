module JM
  module HAL
    # Access HAL links by rel in HAL hashes
    class LinkAccessor < Accessor
      LINKS_ACCESSOR = Accessors::HashKeyAccessor.new("_links", {})

      def initialize(rel, default_value = nil)
        @rel_accessor = Accessors::HashKeyAccessor.new(rel.to_s, default_value)
      end

      def get(hash, *args)
        hash["_links"] ||= {}

        LINKS_ACCESSOR.get(hash, *args).map do |links|
          result = @rel_accessor.get(links, *args)

          case result
          when Success then result
          when Failure then result.sink(["_links"])
          end
        end
      end

      def set(hash, link, *args)
        hash["_links"] ||= {}

        @rel_accessor.set(hash["_links"], link, *args).map do
          Success.new(hash)
        end
      end
    end
  end
end
