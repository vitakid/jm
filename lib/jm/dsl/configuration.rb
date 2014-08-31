module JM
  module DSL
    # A configuration object, that is configured by calling it's methods
    #
    # The intended use is to subclass this and then pass a user-given block to
    # it's constructor.
    #
    # @example
    #   SomeConfiguration.new do
    #     some_setting true
    #   end
    class Configuration
      # Initialize from a block
      def initialize(&block)
        if block
          instance_exec(&block)
        end
      end
    end
  end
end
