require "i18n"

module JM
  module Mappers
    # Map {Failure}s to JSON
    #
    # @see ErrorMapper The mapper, that maps individual errors
    class FailureMapper < DSL::HALMapper
      def initialize
        super(Hash)

        array :errors, mapper: ErrorMapper.new
      end
    end
  end
end
