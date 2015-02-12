require "i18n"

module JM
  module Syncers
    # Map {Failure}s to JSON
    #
    # @see ErrorSyncer The syncer, that maps individual errors
    class FailureSyncer < DSL::HALSyncer
      def initialize
        super

        self.left_factory = Factories::NewFactory.new(Hash)
        self.right_factory = Factories::NewFactory.new(Hash)

        array :errors, mapper: ErrorSyncer.new.to_mapper
      end
    end
  end
end
