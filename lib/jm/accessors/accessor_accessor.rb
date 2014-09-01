module JM
  module Accessors
    # Uses accessor methods (`#name` and `#name=`) to access the object
    class AccessorAccessor < JM::Mapper
      def initialize(name)
        @name = name
        @getter = name.to_sym
        @setter = "#{name}=".to_sym
      end

      def get(object)
        if !object.respond_to?(@getter)
          Failure.new(Errors::MissingGetterError.new([], object, @getter))
        else
          Success.new(object.send(@getter))
        end
      end

      def set(object, data)
        if !object.respond_to?(@setter)
          Failure.new(Errors::MissingSetterError.new([], object, @setter))
        else
          object.send(@setter, data)

          Success.new(object)
        end
      end
    end
  end
end
