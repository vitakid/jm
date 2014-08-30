require "jm/exception"

require "jm/result"
require "jm/success"
require "jm/failure"

require "jm/error"
require "jm/errors/missing_getter_error"
require "jm/errors/missing_setter_error"
require "jm/errors/missing_key_error"
require "jm/errors/unexpected_type_error"

require "jm/results/array_reducer"

require "jm/mapper"
require "jm/mappers/identity_mapper"
require "jm/mappers/array_mapper"
require "jm/mappers/instance_mapper"
require "jm/mappers/mapper_chain"

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

require "jm/dsl/inline_accessor"
require "jm/dsl/inline_mapper"
require "jm/dsl/mapper"
require "jm/dsl/self_link_wrapper"
require "jm/dsl/template_params_accessor"
require "jm/dsl/hal_mapper"

require "jm/version"

# A library for bidirectional JSON mapping
module JM
end
