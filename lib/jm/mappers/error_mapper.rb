module JM
  module Mappers
    # Map {Error}s to JSON
    #
    # @example An example output
    #   # The error
    #   Error.new(%w(person age), :too_young, age: 5)
    #
    #   # The error message
    #   I18n.store_translations(
    #     "en",
    #     jm: {
    #       errors: {
    #         too_young: "%{age} is too young"
    #       }
    #     }
    #   )
    #
    #   # The mapping result
    #   {
    #     "path" => ["person", "age"],
    #     "name" => :too_young,
    #     "message" => "5 is too young"
    #   }
    #
    #   # The message was looked up under the following keys:
    #   # - jm.errors.person.age.too_young
    #   # - jm.errors.age.too_young
    #   # - jm.errors.too_young
    class ErrorMapper < DSL::HALMapper
      # The root scope for error messages
      SCOPE = %w(jm errors)

      def initialize
        super(Error)

        property :path
        property :name
        property :message do
          get do |error|
            prefixes = error.path.reduce([[]]) do |ps, p|
              ps.map { |prefix| prefix + [p] } + [[]]
            end
            keys = prefixes.map { |p| (SCOPE + p + [error.name]).join(".") }
            key = keys.find { |k| I18n.exists?(k) }

            if key
              I18n.t(key, error.params)
            end
          end
        end
      end
    end
  end
end
