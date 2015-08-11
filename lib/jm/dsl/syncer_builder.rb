module JM
  module DSL
    # A mini-DSL to configure {JM::Syncer}s
    #
    # This lets you configure some generally applicable syncer properties, like
    # making a syncer write-only.
    #
    # Subclasses should create their syncer in {#create_syncer}, so that
    # {SyncerBuilder} can wrap it in {#to_syncer}.
    class SyncerBuilder < Builder
      def initialize(write_only: false, write_if: nil, read_if: nil)
        super()

        @write_only = write_only
        @write_if = write_if
        @read_if = read_if
      end

      def write_only(value = true)
        @write_only = value
      end

      def write_if(&block)
        @write_if = block
      end

      def read_if(&block)
        @read_if = block
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

        if @write_only
          syncer = Syncers::WriteOnlySyncer.new(syncer)
        end

        if @write_if
          syncer = Syncers::ConditionalWriteSyncer.new(syncer, @write_if)
        end

        if @read_if
          syncer = Syncers::ConditionalReadSyncer.new(syncer, @read_if)
        end

        syncer
      end
    end
  end
end
