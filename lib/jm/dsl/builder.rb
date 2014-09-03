module JM
  module DSL
    # A builder object to allow users to configure things with blocks
    #
    # The intended use is to subclass this and then pass a user-given block to
    # it's {#configure}.
    #
    # @example
    #   builder = SomeBuilder.new
    #
    #   builder.configure do
    #     some_setting true
    #   end
    class Builder
      def configure(&block)
        if block
          instance_exec(&block)
        end
      end
    end
  end
end
