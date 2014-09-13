module JM
  module Mappers
    # Map Date objects to and from ISO8601 date strings
    class ISO8601DateMapper < Mapper
      def read(string)
        Success.new(Date.iso8601(string))
      rescue ArgumentError
        Failure.new(Errors::DateISO8601IncompatibleError.new([], string))
      end

      def write(date)
        Success.new(date.iso8601)
      end
    end
  end
end
