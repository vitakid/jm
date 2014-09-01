module JM
  module Results
    # Reduce a [{Result}] to {Success}([]) or a {Failure}, if a result is one
    class ArrayReducer
      def reduce(array)
        values, failures = array.each.with_index.reduce([[], Failure.new]) do |(vs, failures), (result, index)|
          case result
          when Success then [vs + [result.value], failures]
          when Failure then [vs, failures + result.sink([index])]
          end
        end

        if failures.errors.length > 0
          failures
        else
          Success.new(values)
        end
      end
    end
  end
end
