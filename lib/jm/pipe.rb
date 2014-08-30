module JM
  # A pipe is an abstraction of copying values from one object to another
  #
  # You can visualize if like a pipe, that goes a left pond to a right aquarium.
  # Fish (date) can swim through it, to move from one side to the other. But the
  # process is also reversible, aka. they can swim back. The side from
  # left-to-right in this is called {#pipe}, while the right-to-left direction
  # is called {#slurp}.
  #
  # @example Pipe, that copies a property to/from a hash
  #   class NamePipe < JM::Pipe
  #     def pipe(person, hash)
  #       hash[:name] = person.name
  #
  #       Success.new(hash)
  #     end
  #
  #     def slurp(person, hash)
  #       person.name = hash[:name]
  #
  #       Success.new(person)
  #     end
  #   end
  class Pipe
    # Pipe data from left to right
    #
    # This SHOULD not modify `right`, if it fails.
    #
    # @param [Object] left Object to read from
    # @param [Object] right Object to write to
    # @return [Result] The modified right object
    def pipe(left, right)
    end

    # Slurp data from right to left
    #
    # This SHOULD not modify `left`, if it fails.
    #
    # @param [Object] left Object to write to
    # @param [Object] right Object to read from
    # @return [Result] The modified left object
    def slurp(left, right)
    end
  end
end
