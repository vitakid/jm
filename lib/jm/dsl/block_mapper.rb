module JM
  module DSL
    # Use a block to define a mapper
    #
    # It also wraps the return values in a {Success}, if it is not already a
    # {Result}.
    class BlockMapper < JM::Mapper
      # @param [Proc] read Definition for {#read}
      # @param [Proc] write Definition for {#write}
      def initialize(read, write)
        @read = read
        @write = write
      end

      def read(object)
        Result.wrap(@read.call(object))
      end

      def write(object)
        Result.wrap(@write.call(object))
      end
    end
  end
end
