module JM
  module DSL
    # A mini-DSL to configure {JM::Syncer}s
    #
    # This lets you configure some generally applicable syncer properties, like
    # making a syncer push-only.
    #
    # Subclasses should create their syncer in {#create_syncer}, so that
    # {SyncerBuilder} can wrap it in {#to_syncer}.
    class SyncerBuilder < Builder
      def initialize(push_only: false, push_if: nil, pull_if: nil)
        super()

        @push_only = push_only
        @push_if = push_if
        @pull_if = pull_if
      end

      # Make the syncer push-only
      def push_only(value = true)
        @push_only = value
      end

      # Make the syncer push conditionally
      #
      # It will only push, if `block` evaluates to something truthy
      def push_if(&block)
        @push_if = block
      end

      # Make the syncer pull conditionally
      #
      # It will only pull, if `block` evaluates to something truthy
      def pull_if(&block)
        @pull_if = block
      end

      # Create a bare syncer
      #
      # Subclasses should overwrite this method to create their configured
      # syncer.
      def create_syncer
        message = "#{self.class.name}#create_syncer is not implemented"

        raise NotImplementedError.new(message)
      end

      # Create a configured syncer
      def to_syncer
        syncer = create_syncer

        if @push_only
          syncer = Syncers::PushOnlySyncer.new(syncer)
        end

        if @push_if
          syncer = Syncers::ConditionalPushSyncer.new(syncer, @push_if)
        end

        if @pull_if
          syncer = Syncers::ConditionalPullSyncer.new(syncer, @pull_if)
        end

        syncer
      end
    end
  end
end
