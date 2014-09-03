module JM
  module Results
    # Reduce a [{Result}] to {Success}([]) or a {Failure}, if a result is one
    class ArrayReducer
      def reduce(array)
        enumerator = array.each.with_index
        acc = [[], Failure.new]
        values, failures = enumerator.reduce(acc) do |(vs, fs), (result, index)|
          case result
          when Success then [vs + [result.value], fs]
          when Failure then [vs, fs + result.sink([index])]
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
