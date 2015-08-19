module JM
  # A mapper is an abstraction of the conversion of values
  #
  # A mapper can convert objects from some kind of source type/structure to some
  # kind of target type/structure. What this precisely means depends on the
  # specific subclass of {Mapper}.
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
  #     def read(string, *args)
  #       Date.iso8601(string)
  #     end
  #
  #     def write(date, *args)
  #       date.iso8601
  #     end
  #   end
  class Mapper
    # Map an object from target to source
    #
    # If a mapper calls other mappers, it may only pass on a subset of the
    # options. For instance a mapper might take own options as well as options
    # for a wrapped mapper object and only pass on some of the original options
    # or it might construct a totally new options object for the wrapped mapper.
    #
    # The context should always be passed unmodified.
    #
    # It is important, that neither options nor context are modified in-place,
    # because a higher-level mapper might reuse these objects.
    #
    # @param [Object] object The target representation of an object
    # @param [Hash] options Additional options
    #   The specific options available depend on the {Mapper} subclass.
    # @param [Hash] context A hash of values that define a context for the
    #   operation. This map could include the requesting user or the query
    #   parameters.
    # @return [Result] The source representation of object
    def read(object, options = {}, context = {})
    end

    # Map an object from source to target
    #
    # If a mapper calls other mappers, it may only pass on a subset of the
    # options. For instance a mapper might take own options as well as options
    # for a wrapped mapper object and only pass on some of the original options
    # or it might construct a totally new options object for the wrapped mapper.
    #
    # The context should always be passed unmodified.
    #
    # It is important, that neither options nor context are modified in-place,
    # because a higher-level mapper might reuse these objects.
    #
    # @param [Object] object The source representation of an object
    # @param [Hash] options Additional options
    #   The specific options available depend on the {Mapper} subclass.
    # @param [Hash] context A hash of values that define a context for the
    #   operation. This map could include the requesting user or the query
    #   parameters.
    # @return [Result] The target representation of object
    def write(object, options = {}, context = {})
    end
  end
end
