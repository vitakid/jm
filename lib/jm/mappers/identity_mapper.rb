module JM
  module Mappers
    # A mapper that maps everything to itself
    #
    # This is supposed to be used as a default value in places, where a mapper
    # is expected.
    class IdentityMapper < Mapper
      def read(object)
        Success.new(object)
      end

      def write(object)
        Success.new(object)
      end
    end
  end
end
