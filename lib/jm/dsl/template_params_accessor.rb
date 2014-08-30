require "addressable/template"

module JM
  module DSL
    # Read and write URI template parameters to and from objects
    #
    # So for example if the URI template is `"/people/{name}-{age}"`, this
    # accessor will map `Person.new("Marten", 21)` to `{ name: "Marten", age: 21
    # }` and back.
    class TemplateParamsAccessor < Accessor
      def initialize(uri_template)
        template = Addressable::Template.new(uri_template)

        @getters = template.variables.map(&:to_sym)
        @setters = @getters.each_with_object({}) do |getter, hash|
          hash[getter.to_s] = "#{getter}=".to_sym
        end
      end

      def get(object)
        params = @getters.map do |getter|
          [getter, object.send(getter)]
        end.to_h

        Success.new(params)
      end

      def set(object, params)
        params.map do |param, value|
          object.send(@setters[param], value)
        end

        Success.new(object)
      end
    end
  end
end
