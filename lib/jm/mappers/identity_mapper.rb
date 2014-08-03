module JM
  module Mappers
    # A mapper that maps everything to itself
    #
    # This is supposed to be used as a default value in places, where a mapper
    # is expected.
    class IdentityMapper < Mapper
      def read(object)
        object
      end

      def write(object)
        object
      end
    end
  end
end
