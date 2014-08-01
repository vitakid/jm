require "jm/mapper"

module JM
  module Mappers
    # A mapper, that does nothing
    #
    # This is intended to be used as a default value in positions where a
    # {Mapper} is required.
    class IdentityMapper < Mapper
      def read(object, data)
        data
      end

      def write(object, data)
        object
      end
    end
  end
end
