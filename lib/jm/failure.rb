module JM
  # A list of errors representing a failed operation
  #
  # Failures can be converted to JSON with {#to_json}, so that you can send the
  # error messages back to the client.
  class Failure < Result
    MAPPER = Pipes::FailurePipe.new.to_mapper

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

    # Prepend a path to all errors (sink them deeper into a structure)
    #
    # @param [Array] path Path to prepend
    # @return [Failure] Failure with sunken errors
    def sink(path)
      Failure.new(@errors.map { |e| e.sink(path) })
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

    def to_json
      MAPPER.write(self).value.to_json
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
