module JM
  module DSL
    # Use blocks to define an accessor
    #
    # It also wraps the return value in a {Success}, if it is not already a
    # {Result}.
    class BlockAccessor < Accessor
      # @param [Proc] get Definition for {#get}
      # @param [Proc] set Definition for {#set}
      def initialize(get, set)
        @get = get
        @set = set
      end

      def get(*args)
        Result.wrap(@get.call(*args))
      end

      def set(*args)
        Result.wrap(@set.call(*args))
      end
    end
  end
end
