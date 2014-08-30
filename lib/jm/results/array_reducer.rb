module JM
  module Results
    # Reduce a [{Result}] to {Success}([]) or a {Failure}, if a result is one
    class ArrayReducer
      def reduce(array)
        if array.any? { |item| item.is_a?(Failure) }
          array
            .select { |item| item.is_a?(Failure) }
            .reduce(&:+)
        else
          Success.new(array.map(&:value))
        end
      end
    end
  end
end
