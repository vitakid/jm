module JM
  # The result of a successful operation
  class Success < Result
    # The resulting value
    attr_reader :value

    def initialize(value)
      @value = value
    end

    # Map a block over the value
    #
    # @yield [Object] The contained value
    # @return Whatever the block returns
    def map
      yield(@value)
    end

    def ==(other)
      if equal?(other)
        true
      elsif other.class != self.class
        false
      else
        @value == other.value
      end
    end

    alias_method(:eql?, :==)

    def hash
      @errors.hash
    end
  end
end
