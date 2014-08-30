module JM
  # A mapper is an abstraction of the conversion of values
  #
  # A mapper can convert objects from some kind of left type/structure to some
  # kind of right type/structure. What this precisely means, is left to the
  # subclasses of {Mapper}.
  #
  # You can visualize it like this
  #
  # ```
  #      <-- read  ---
  #     /             \
  # Left               Right
  #     \             /
  #      --- write -->
  # ```
  #
  # @example A date-to-string mapper
  #   class ISOMapper < JM::Mapper
  #     def read(string)
  #       Date.iso8601(string)
  #     end
  #
  #     def write(date)
  #       date.iso8601
  #     end
  #   end
  class Mapper
    # Map an object from right to left
    #
    # @param [Object] object The right representation of an object
    # @return [Result] The left representation of object
    def read(object)
    end

    # Map an object from left to right
    #
    # @param [Object] object The left representation of an object
    # @return [Result] The right representation of object
    def write(object)
    end
  end
end
