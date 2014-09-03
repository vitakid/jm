module JM
  # A reason for a failure
  #
  # Errors have a name and parameters, that might be used for debugging or
  # generating error messages.
  #
  # @example Division by zero error
  #   # You cannot divide 25 by 0
  #   Error.new([], :division_by_zero, divident: 25)
  class Error
    # A path into a data structure, that tells you the origin of the failure
    #
    # @example Path into a nested hash
    #   hash = { a: { "path" => false} }
    #
    #   # The path to false
    #   [:a, "path"]
    attr_reader :path

    attr_reader :name

    attr_reader :params

    # @param [Array] path A path into a data structure, that tells you the
    #   origin of the failure
    # @param [Symbol] name Some symbol identifying this type of error
    # @param [Hash] params Parameters, that better describe the error cause
    def initialize(path, name, params = {})
      @path = path
      @name = name
      @params = params
    end

    # Prepend a path and thereby sink it deeper into a structure
    #
    # @param [Array] path Path to prepend
    # @return [Error] Sunken error
    def sink(path)
      Error.new(path + @path, @name, @params)
    end

    def ==(other)
      if equal?(other)
        true
      elsif other.class != self.class
        false
      else
        path == other.path &&
          name == other.name &&
          params == other.params
      end
    end

    alias_method(:eql?, :==)

    def hash
      [@path, @name, @params].hash
    end
  end
end
