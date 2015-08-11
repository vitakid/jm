module JM
  module DSL
    # A builder defines a mini-DSL for configuring the creation of an object
    #
    # The intended use is to subclass this and then pass a user-given block to
    # {#configure}.
    #
    # @example
    #   class SomeBuilder < Builder
    #     def some_setting(value)
    #       @some_setting = value
    #     end
    #   end
    #
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
