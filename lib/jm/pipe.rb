module JM
  # A pipe is an abstraction of copying values from one object to another
  #
  # You can visualize it like a pipe, that goes from a left pond to a right
  # aquarium.  Fish (data) can swim through it, to move from one side to the
  # other. But the process is also reversible, aka. they can swim back. The side
  # from left-to-right in this is called {#pump}, while the right-to-left
  # direction is called {#suck}.
  #
  # When {#left_factory} and {#right_factory} are set, you can use any pipe as a
  # {Mapper}, because the missing object can be instantiated on the fly.
  #
  # @example Pipe, that copies a property to/from a hash
  #   class NamePipe < JM::Pipe
  #     def pump(person, hash)
  #       hash[:name] = person.name
  #
  #       Success.new(hash)
  #     end
  #
  #     def suck(person, hash)
  #       person.name = hash[:name]
  #
  #       Success.new(person)
  #     end
  #   end
  class Pipe
    # The left factory instantiates the target object when {Mapper#read}ing
    #
    # @return [Factory]
    attr_accessor :left_factory

    # The right factory instantiates the target object when {Mapper#write}ing
    #
    # @return [Factory]
    attr_accessor :right_factory

    # Pump data from left to right
    #
    # This SHOULD NOT modify `right`, if it fails.
    #
    # @param [Object] left Object to read from
    # @param [Object] right Object to write to
    # @return [Result] The modified right object
    def pump(left, right)
      message = "#{self.class.name}#pump is not implemented"

      raise NotImplementedError.new(message)
    end

    # Suck data from right to left
    #
    # This SHOULD NOT modify `left`, if it fails.
    #
    # @param [Object] left Object to write to
    # @param [Object] right Object to read from
    # @return [Result] The modified left object
    def suck(left, right)
      message = "#{self.class.name}#suck is not implemented"

      raise NotImplementedError.new(message)
    end

    def to_mapper
      Mappers::PipeMapper.new(self)
    end
  end
end
