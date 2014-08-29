module JM
  # A reason for a failure
  #
  # Errors have a name and parameters, that might be used for debugging or
  # generating error messages.
  #
  # @example Division by zero error
  #   # You cannot divide 25 by 0
  #   Error.new(:division_by_zero, divident: 25)
  class Error
    attr_reader :name
    attr_reader :params

    # @param [Symbol] name Some symbol identifying this type of error
    # @param [Hash] params Parameters, that better describe the error cause
    def initialize(name, params = {})
      @name = name
      @params = params
    end

    def ==(other)
      if equal?(other)
        true
      elsif other.class != self.class
        false
      else
        name == other.name &&
          params == other.params
      end
    end

    alias_method(:eql?, :==)

    def hash
      [@name, @params].hash
    end
  end
end
