module JM
  module Errors
    # Something should have been a JSON object (Hash in ruby)
    class NotAnObjectError < Error
      def initialize(path)
        super(path, :not_an_object)
      end
    end
  end
end
