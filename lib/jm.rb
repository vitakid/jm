require "jm/exception"

require "jm/mapper"
require "jm/mappers/identity_mapper"
require "jm/mappers/array_mapper"

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

require "jm/dsl/mapper"
require "jm/dsl/self_link_mapper"
require "jm/dsl/template_params_accessor"
require "jm/dsl/hal_mapper"

require "jm/version"

# A library for bidirectional JSON mapping
module JM
end
