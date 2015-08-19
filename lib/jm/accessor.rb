module JM
  # An accessor is an abstraction over accessing a data structure
  #
  # @example Access the fifth character
  #   class FithCharacterAccessor < JM::Accessor
  #     def get(string, *args)
  #       string[4]
  #     end
  #
  #     def set(string, char, *args)
  #       string[4] = char
  #     end
  #   end
  class Accessor
    # Read some data from object
    #
    # If an accessor calls other accessors, it may only pass on a subset of the
    # options. For instance an accessor might take own options as well as
    # options for a wrapped accessor object and only pass on some of the
    # original options or it might construct a totally new options object for
    # the wrapped accessor.
    #
    # The context should always be passed unmodified.
    #
    # It is important, that neither options nor context are modified in-place,
    # because a higher-level accessor might reuse these objects.
    #
    # @param [Object] object Object to read from
    # @param [Hash] options Additional options
    #   The specific options available depend on the {Mapper} subclass.
    # @param [Hash] context A hash of values that define a context for the
    #   operation. This map could include the requesting user or the query
    #   parameters.
    # @return [Result] Read data
    def get(object, options = {}, context = {})
    end

    # Write some data to object
    #
    # This SHOULD not modify `object`, if it fails.
    #
    # If an accessor calls other accessors, it may only pass on a subset of the
    # options. For instance an accessor might take own options as well as
    # options for a wrapped accessor object and only pass on some of the
    # original options or it might construct a totally new options object for
    # the wrapped accessor.
    #
    # The context should always be passed unmodified.
    #
    # It is important, that neither options nor context are modified in-place,
    # because a higher-level accessor might reuse these objects.
    #
    # @param [Object] object Object to write to
    # @param [Object] value Value to write
    # @param [Hash] options Additional options
    #   The specific options available depend on the {Mapper} subclass.
    # @param [Hash] context A hash of values that define a context for the
    #   operation. This map could include the requesting user or the query
    #   parameters.
    # @return [Result] object with value set
    def set(object, value, options = {}, context = {})
    end
  end
end
