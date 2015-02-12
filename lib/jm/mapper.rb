module JM
  # A mapper is an abstraction of the conversion of values
  #
  # A mapper can convert objects from some kind of source type/structure to some
  # kind of target type/structure. What this precisely means, is source to the
  # subclasses of {Mapper}.
  #
  # You can visualize it like this
  #
  # ```
  #        -<- read  -<-
  #       /             \
  # Source               Target
  #       \             /
  #        ->- write ->-
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
    # Map an object from target to source
    #
    # @param [Object] object The target representation of an object
    # @return [Result] The source representation of object
    def read(object)
    end

    # Map an object from source to target
    #
    # @param [Object] object The source representation of an object
    # @return [Result] The target representation of object
    def write(object)
    end
  end
end
