require "jm/exception"

require "jm/result"
require "jm/success"
require "jm/failure"

require "jm/results/array_reducer"

require "jm/error"
require "jm/errors/missing_getter_error"
require "jm/errors/missing_setter_error"
require "jm/errors/missing_key_error"
require "jm/errors/unexpected_type_error"

require "jm/validator"
require "jm/validators/identity_validator"
require "jm/validators/block_validator"
require "jm/validators/predicate"

require "jm/mapper"
require "jm/mappers/identity_mapper"
require "jm/mappers/array_mapper"
require "jm/mappers/instance_mapper"
require "jm/mappers/mapper_chain"
require "jm/mappers/validated_mapper"
require "jm/mappers/sinking_mapper"

require "jm/accessor"
require "jm/accessors/nil_accessor"
require "jm/accessors/mapped_accessor"
require "jm/accessors/accessor_accessor"
require "jm/accessors/hash_key_accessor"

require "jm/pipe"
require "jm/pipes/composite_pipe"
require "jm/pipes/read_only_pipe"
require "jm/pipes/conditional_read_pipe"
require "jm/pipes/conditional_write_pipe"

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
require "jm/dsl/mapper"
require "jm/dsl/self_link_wrapper"
require "jm/dsl/template_params_accessor"
require "jm/dsl/hal_mapper"

require "jm/version"

# A library for bidirectional JSON mapping
module JM
end
