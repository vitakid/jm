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

## Manual

There are three concepts, that are the key to understanding `jm`.

- *Accessors* abstract reading from and writing to objects
- *Mappers* map values from one representation to another
- *Pipes* give you total control over synchronizing your objects and their JSON
representations

`jm` strives to pick good defaults for you, but at the same time give you the
possibility to take control and implement arbitrarily complex mapping
behavior. A simple example might be, that you would like to map a person's name
to and from JSON. By default `jm` reads the name with `#name` and writes it with
`#name=` and it should be good enough in a lot of cases. But when the situation
gets more complex `jm` gets out of your way and you can pass an accessor, that
reads by concatenating the `#first_name` and `#last_name` and writes by
splitting the name at the last space and saves the values as first and last
name.

### Accessors

You pass an accessor, when you want to customize how to read and write your
object. Let's implement an accessor, that accesses the `name` property of an
object.

```ruby
class NameAccessor < JM::Accessor
  def get(object)
    object.name
  end

  def set(object, name)
    object.name = name
  end
end

Person = Struct.new(:name)

person = Person.new("jaba")
accessor = NameAccessor.new

accessor.get(person)
# => "jaba"

accessor.set(person, "Ruffy")
person.name
# => "Ruffy"
```

Some useful accessors are already defined

- [`JM::Accessors::AccessorAccessor`](/lib/jm/accessors/accessor_accessor.rb)
  accesses a property with normal ruby accessors
- [`JM::Accessors::HashKeyAccessor`](/lib/jm/accessors/hash_key_accessor.rb)
  accesses a hash with the `#[]` and `#[]=` methods

### Mapper

Mappers transform values. So you pass a mapper, when you would like to transform
a value during the mapping process. Let's say you would like to serialize `Date`
objects to a custom format.

```ruby
class DateMapper < JM::Mapper
  def read(string)
    Date.rfc822(string)
  end

  def write(date)
    date.rfc822
  end
end

mapper = DateMapper.new

mapper.write(Date.new(2014, 8, 13))
# => "Wed, 13 Aug 2014 00:00:00 +0000"

mapper.read("Wed, 13 Aug 2014 00:00:00 +0000")
# => #<Date: 2014-08-13 ((2456883j,0s,0n),+0s,2299161j)>
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
