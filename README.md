# JM - Bidirectional JSON mapping

## Usage

```ruby
require "jm"

Person = Struct.new(:name, :pets)
Pet = Struct.new(:name, :age)

class PetMapper < JM::DSL::HALMapper
  def initialize
    super(Pet)

    self_link "/pets/{name}" do
      def read(params)
        Pet.new(params["name"])
      end

      def write(pet)
        { name: pet.name }
      end
    end

    property :name
    property :age
  end
end

class PersonMapper < JM::DSL::HALMapper
  def initialize
    super(Person)

    self_link "/people/{name}" do
      def read(params)
        Person.new(params["name"])
      end

      def write(person)
        { name: person.name }
      end
    end

    property :name
    array :pets, PetMapper.new
  end
end

mapper = PersonMapper.new
p = Person.new("Dog Owner", [Pet.new("A", 5), Pet.new("B", 10)])

hash = mapper.write(p)
# => {"_links"=>{"self"=>{"href"=>"/people/Dog%20Owner"}},
#      "name"=>"Dog Owner",
#      "pets"=>
#       [{"_links"=>{"self"=>{"href"=>"/pets/A"}}, "name"=>"A", "age"=>5},
#        {"_links"=>{"self"=>{"href"=>"/pets/B"}}, "name"=>"B", "age"=>10}]}

hal = {
  "_links" => { "self" => { "href" => "/people/Cat%20Owner" } },
  "name" => "Cat Owner",
  "pets" => [
    {
      "_links" => { "self" => { "href" => "/pets/D" } },
      "name" => "D",
      "age" => 1
    },
    {
      "_links" => {"self" => { "href" => "/pets/Cat" } },
      "name" => "Cat",
      "age" => 19
    }
  ]
}

mapper.read(hal)
# => #<struct Person name="Cat Owner", pets=[#<struct Pet name="D", age=1>, #<struct Pet name="Cat", age=19>]>
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem "jm"
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install jm
```

## Contributing

1. Fork it ( http://github.com/CQQL/jm/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
