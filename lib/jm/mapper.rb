module JM
  # A {Mapper} reads data from an object and writes it back
  #
  # Mathematically speaking a {Mapper} is a bijection.
  class Mapper
    # Read data back in as object
    #
    # @return [Object] The parsed object representation of data
    def read(data)
    end

    # Write object out as data
    #
    # @return [Object] The serialized representation of object
    def write(object)
    end
  end
end
