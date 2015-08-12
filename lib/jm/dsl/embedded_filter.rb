module JM
  module DSL
    # Wraps a syncer and attaches a specific name to it
    #
    # This filter only forwards {#push} and {#pull} calls if the associated name
    # is enabled in the syncer options.
    #
    # The intended use case is to let the user pass some configuration to
    # control which linked resources should be embedded.
    class EmbeddedFilter < Syncer
      def initialize(name, syncer)
        @name = name.to_s
        @syncer = syncer
      end

      def push(source, target, options = {}, context = {})
        options = EmbeddedFilterOptions.new(options)

        if options.enabled?(@name)
          @syncer.push(source, target, options.suboptions(@name), context)
        else
          JM::Success.new(target)
        end
      end

      def pull(source, target, options = {}, context = {})
        options = EmbeddedFilterOptions.new(options)

        if options.enabled?(@name)
          @syncer.pull(source, target, options.suboptions(@name), context)
        else
          JM::Success.new(source)
        end
      end
    end
  end
end
