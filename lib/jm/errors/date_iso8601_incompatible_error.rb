module JM
  module Errors
    # The string was not an ISO8601 date
    class DateISO8601IncompatibleError < Error
      def initialize(path)
        super(path, :date_iso8601_incompatible)
      end
    end
  end
end
