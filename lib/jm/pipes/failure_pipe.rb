require "i18n"

module JM
  module Pipes
    # Map {Failure}s to JSON
    #
    # @see ErrorPipe The pipe, that maps individual errors
    class FailurePipe < DSL::HALPipe
      def initialize
        super

        self.left_factory = Factories::NewFactory.new(Hash)
        self.right_factory = Factories::NewFactory.new(Hash)

        array :errors, mapper: ErrorPipe.new.to_mapper
      end
    end
  end
end
