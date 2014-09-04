module JM
  # Validates objects
  #
  # @see Validators::Predicate The most likely base class for custom validators
  class Validator
    # Validate an object
    #
    # If object is valid, it should return `JM::Success.new(object)`. Otherwise
    # it should return a {JM::Failure}.
    #
    # @param [Object] object Object to validate
    # @return [JM::Result]
    def validate(object)
    end
  end
end
