module JM
  module DSL
    # Utility functions to parse the options passed to {EmbeddedBuilder}
    class EmbeddedFilterOptions
      def initialize(options)
        if options.is_a?(Hash)
          @options = options
        else
          @options = {}
        end
      end

      # Is the relation enabled?
      def enabled?(relation)
        @options.fetch(relation, false)
      end

      # Filter the options to pass on to the embedded mapper
      def suboptions(relation)
        @options.fetch(relation, nil)
      end
    end
  end
end
