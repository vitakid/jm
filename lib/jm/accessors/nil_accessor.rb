module JM
  module Accessors
    # Always returns nil and does not set anything
    #
    # This should be used as a default value in positions, where an {Accessor}
    # is expected.
    class NilAccessor < Accessor
      def get(object)
        Success.new(nil)
      end

      def set(object, value)
        Success.new(nil)
      end
    end
  end
end
