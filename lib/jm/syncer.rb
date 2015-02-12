module JM
  # A syncer is an abstraction of copying values from one object to another
  #
  # It takes a certain aspect of the source object and pushes it onto the target
  # object or pulls it back onto the source object. An aspect is for example the
  # value of a certain attribute. Then you can combine n syncers to copy all n
  # attributes at once.
  #
  # When {#left_factory} and {#right_factory} are set, you can use any syncer as
  # a {Mapper}, because the missing object can be instantiated on the fly.
  #
  # @example Syncer, that copies a property to/from a hash
  #   class NameSyncer < JM::Syncer
  #     def push(person, hash)
  #       hash[:name] = person.name
  #
  #       Success.new(hash)
  #     end
  #
  #     def pull(person, hash)
  #       person.name = hash[:name]
  #
  #       Success.new(person)
  #     end
  #   end
  class Syncer
    # The left factory instantiates the target object when {Mapper#read}ing
    #
    # @return [Factory]
    attr_accessor :left_factory

    # The right factory instantiates the target object when {Mapper#write}ing
    #
    # @return [Factory]
    attr_accessor :right_factory

    # Push data from left to right
    #
    # This SHOULD NOT modify `right`, if it fails.
    #
    # @param [Object] left Object to read from
    # @param [Object] right Object to write to
    # @return [Result] The modified right object
    def push(left, right)
      message = "#{self.class.name}#push is not implemented"

      raise NotImplementedError.new(message)
    end

    # Pull data from right to left
    #
    # This SHOULD NOT modify `left`, if it fails.
    #
    # @param [Object] left Object to write to
    # @param [Object] right Object to read from
    # @return [Result] The modified left object
    def pull(left, right)
      message = "#{self.class.name}#pull is not implemented"

      raise NotImplementedError.new(message)
    end

    def to_mapper
      Mappers::SyncerMapper.new(self)
    end
  end
end
