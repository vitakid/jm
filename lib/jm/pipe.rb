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
  #     end
  #
  #     def slurp(person, hash)
  #       person.name = hash[:name]
  #     end
  #   end
  class Pipe
    # Pipe data from left to right
    #
    # @param [Object] left Object to read from
    # @param [Object] right Object to write to
    def pipe(left, right)
    end

    # Slurp data from right to left
    #
    # @param [Object] left Object to write to
    # @param [Object] right Object to read from
    def slurp(left, right)
    end
  end
end
