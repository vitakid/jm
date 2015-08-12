module JM
  # A syncer is an abstraction of copying values from one object to another
  #
  # It takes a certain aspect of the source object and pushes it onto the target
  # object or pulls it back onto the source object. An aspect is for example the
  # value of an attribute. Then you can combine n syncers to copy all n
  # attributes at once.
  #
  # When {#source_factory} and {#target_factory} are set, you can use any syncer
  # as a {Mapper}, because the missing object can be instantiated on the fly.
  #
  # @example Syncer, that copies a property to/from a hash
  #   class NameSyncer < JM::Syncer
  #     def push(person, hash, *args)
  #       hash[:name] = person.name
  #
  #       Success.new(hash)
  #     end
  #
  #     def pull(person, hash, *args)
  #       person.name = hash[:name]
  #
  #       Success.new(person)
  #     end
  #   end
  class Syncer
    # The source factory instantiates the target object when {Mapper#read}ing
    #
    # @return [Factory]
    attr_accessor :source_factory

    # The target factory instantiates the target object when {Mapper#write}ing
    #
    # @return [Factory]
    attr_accessor :target_factory

    # Push data from `source` to `target`
    #
    # This SHOULD NOT modify `target`, if it fails.
    #
    # If a syncer calls other syncers, it may only pass on a subset of the
    # options. For instance a syncer might take own options as well as options
    # for a wrapped syncer object and only pass on some of the original options
    # or it might construct a totally new options object for the wrapped syncer.
    #
    # The context should always be passed unmodified and is intended for use in
    # user-defined hooks, e.g. {SyncerBuilder#write_if}.
    #
    # It is important, that neither options nor context are modified in-place,
    # because a higher-level syncer might reuse these objects.
    #
    # @param [Object] source Object to read from
    # @param [Object] target Object to write to
    # @param [Hash] options Additional options
    #   The specific options available depend on the {Syncer} subclass.
    # @param [Hash] context A hash of values that define a context for the
    #   operation. This map could include the requesting user or the query
    #   parameters.
    # @return [Result] The modified target object
    def push(source, target, options = {}, context = {})
      message = "#{self.class.name}#push is not implemented"

      raise NotImplementedError.new(message)
    end

    # Pull data from `target` to `source`
    #
    # This SHOULD NOT modify `source`, if it fails.
    #
    # If a syncer calls other syncers, it may only pass on a subset of the
    # options. For instance a syncer might take own options as well as options
    # for a wrapped syncer object and only pass on some of the original options
    # or it might construct a totally new options object for the wrapped syncer.
    #
    # The context should always be passed unmodified and is intended for use in
    # user-defined hooks, e.g. {SyncerBuilder#write_if}.
    #
    # It is important, that neither options nor context are modified in-place,
    # because a higher-level syncer might reuse these objects.
    #
    # @param [Object] source Object to write to
    # @param [Object] target Object to read from
    # @param [Hash] options Additional options
    #   The specific options available depend on the {Syncer} subclass.
    # @param [Hash] context A hash of values that define a context for the
    #   operation. This map could include the requesting user or the query
    #   parameters.
    # @return [Result] The modified source object
    def pull(source, target, options = {}, context = {})
      message = "#{self.class.name}#pull is not implemented"

      raise NotImplementedError.new(message)
    end

    def to_mapper
      Mappers::SyncerMapper.new(self)
    end
  end
end
