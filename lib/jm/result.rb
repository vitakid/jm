module JM
  # A general result, which can either be a success or a failure
  #
  # When you need to extract/work with the value of a result, you should prefer
  # to work with {#map}, because this will pass the value, if the result was a
  # success, and will return the failure if the result was one already. So you
  # get error handling for free.
  #
  # @example Mapping over a result
  #   # result is now a Result
  #   result = some_function_that_might_fail
  #
  #   # Returns the return value of the block, if result is a success, and
  #   # returns result, if it is a failure
  #   result.map do |value|
  #     # work with value
  #     value ** 2 + 5
  #   end
  # @see Success
  # @see Failure
  class Result
    # Map the block over the contained value
    #
    # @yield [Object] The contained value
    def map(&block)
    end

    # Wrap an object in a {Result}, if it is not one already
    #
    # @api private
    def self.wrap(result)
      if result.is_a?(Result)
        result
      else
        Success.new(result)
      end
    end
  end
end
