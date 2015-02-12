require "jm/exception"

require "jm/results/array_reducer"

require "jm/error"
require "jm/errors/missing_getter_error"
require "jm/errors/missing_setter_error"
require "jm/errors/not_an_object_error"
require "jm/errors/unexpected_type_error"
require "jm/errors/date_iso8601_incompatible_error"
require "jm/errors/invalid_link_error"
require "jm/errors/no_regexp_match_error"
require "jm/errors/string_length_out_of_range_error"

require "jm/validator"
require "jm/validators/identity_validator"
require "jm/validators/block_validator"
require "jm/validators/predicate"
require "jm/validators/regexp_validator"
require "jm/validators/length_in_range_validator"

require "jm/factory"
require "jm/factories/new_factory"

require "jm/mapper"
require "jm/mappers/identity_mapper"
require "jm/mappers/array_mapper"
require "jm/mappers/instance_mapper"
require "jm/mappers/mapper_chain"
require "jm/mappers/validated_mapper"
require "jm/mappers/sinking_mapper"
require "jm/mappers/iso8601_date_mapper"
require "jm/mappers/syncer_mapper"
require "jm/mappers/when_value"

require "jm/accessor"
require "jm/accessors/nil_accessor"
require "jm/accessors/mapped_accessor"
require "jm/accessors/accessor_accessor"
require "jm/accessors/hash_key_accessor"

require "jm/syncer"
require "jm/syncers/composite_syncer"
require "jm/syncers/write_only_syncer"
require "jm/syncers/conditional_read_syncer"
require "jm/syncers/conditional_write_syncer"

require "jm/hal/link_mapper"
require "jm/hal/link_accessor"
require "jm/hal/embedded_accessor"

require "jm/dsl/validator"
require "jm/dsl/block_accessor"
require "jm/dsl/block_mapper"
require "jm/dsl/builder"
require "jm/dsl/property_builder"
require "jm/dsl/array_builder"
require "jm/dsl/self_link_builder"
require "jm/dsl/link_builder"
require "jm/dsl/embedded_builder"
require "jm/dsl/embeddeds_builder"
require "jm/dsl/syncer"
require "jm/dsl/self_link_wrapper"
require "jm/dsl/template_params_accessor"
require "jm/dsl/hal_syncer"

require "jm/syncers/error_syncer"
require "jm/syncers/failure_syncer"

require "jm/result"
require "jm/success"
require "jm/failure"

require "jm/version"

# A library for bidirectional JSON mapping
module JM
  pattern = File.join(File.dirname(__FILE__), "..", "locales", "*.yml")
  files = Dir.glob(pattern)

  I18n.load_path += files
end
