module JM
  module Accessors
    # Uses accessor methods (#name and #name=) to access the object
    class AccessorAccessor < JM::Mapper
      def initialize(name)
        @name = name
        @getter = name.to_sym
        @setter = "#{name}=".to_sym
      end

      def get(object)
        object.send(@getter)
      end

      def set(object, data)
        object.send(@setter, data)
      end
    end
  end
end
