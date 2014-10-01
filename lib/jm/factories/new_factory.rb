module JM
  module Factories
    # Instantiates objects by just calling `klass.new`
    class NewFactory < Factory
      def initialize(klass)
        @klass = klass
      end

      def create
        @klass.new
      end
    end
  end
end
