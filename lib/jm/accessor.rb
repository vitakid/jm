module JM
  # An accessor is an abstraction over accessing a data structure
  #
  # @example Access the fifth character
  #   class FithCharacterAccessor < JM::Accessor
  #     def get(string)
  #       string[4]
  #     end
  #
  #     def set(string, char)
  #       string[4] = char
  #     end
  #   end
  class Accessor
    # Read some data from object
    #
    # @param [Object] object Object to read from
    # @return [Result] Read data
    def get(object)
    end

    # Write some data to object
    #
    # This SHOULD not modify `object`, if it fails.
    #
    # @param [Object] object Object to write to
    # @param [Object] value Value to write
    # @return [Result] object with value set
    def set(object, value)
    end
  end
end
