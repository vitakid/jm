module JM
  # A {Mapper} reads data from an object and writes it back
  #
  # Mathematically speaking a {Mapper} is a bijection.
  class Mapper
    # Read data from object
    def read(object, data)
    end

    # Write data back to object
    #
    # @return object [Object] The updated object
    def write(object, data)
    end
  end
end
