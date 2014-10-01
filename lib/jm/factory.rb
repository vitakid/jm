module JM
  # A factory abstracts the instantiation of objects
  #
  # By using a factory other classes can instantiate user defined classes
  # without having to know the instantiation process.
  class Factory
    # Instantiates an object
    #
    # @return [Object] The newly created object
    def create
      message = "#{self.class.name}#create is not implemented"

      raise NotImplementedError.new(message)
    end
  end
end
