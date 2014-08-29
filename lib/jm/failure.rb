module JM
  # A list of errors representing a failed operation
  class Failure < Result
    # @return [[JM::Error]] Errors, that lead to the failure
    attr_reader :errors

    # @param [JM::Error, [JM::Error]] errors Errors, stating the reasons behind
    #   the failure
    def initialize(errors = [])
      if errors.is_a?(JM::Error)
        errors = Array(errors)
      end

      @errors = errors
    end

    # Combine two failures
    def +(other)
      Failure.new(@errors + other.errors)
    end

    # Return self
    #
    # Mapping over a failure is a noop, because you cannot proceed computations
    # on the basis of a failed step.
    #
    # @return This same failure
    def map(&block)
      self
    end

    def ==(other)
      if equal?(other)
        true
      elsif other.class != self.class
        false
      else
        @errors == other.errors
      end
    end

    alias_method(:eql?, :==)

    def hash
      [@name, @params].hash
    end
  end
end
