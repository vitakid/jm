# JM - Bidirectional JSON mapping

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Usage](#usage)
- [Concepts](#concepts)
  - [Success and Failure](#success-and-failure)
  - [Accessors](#accessors)
  - [Mapper](#mapper)
  - [Syncers](#syncers)
- [Documentation](#documentation)
- [Installation](#installation)
- [Contributing](#contributing)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Usage

```ruby
require "jm"

Person = Struct.new(:name, :pets)
Pet = Struct.new(:name, :age)

class PetMapper < JM::DSL::HALMapper
  def initialize
    super(Pet)

    self_link "/pets/{name}" do
      read do |params|
        Pet.new(params["name"])
      end

      write do |pet|
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
      read do |params|
        Person.new(params["name"])
      end

      write do |person|
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

## Concepts

There are three concepts, that are the key to understanding `jm`.

- *Accessors* abstract reading from and writing to objects
- *Mappers* map values from one representation to another
- *Syncers* give you total control over synchronizing your objects and their
  JSON representations

`jm` strives to pick good defaults for you, but at the same time give you the
possibility to take control and implement arbitrarily complex mapping
behavior. A simple example might be, that you would like to map a person's name
to and from JSON. By default `jm` reads the name with `#name` and writes it with
`#name=` and it should be good enough in a lot of cases. But when the situation
gets more complex `jm` gets out of your way and you can pass an accessor, that
reads by concatenating the `#first_name` and `#last_name` and writes by
splitting the name at the last space and saves the values as first and last
name.

### Success and Failure

First you have to understand, that every operation could potentially
fail. Reading a value from a hash could fail. Constructing an object from a
string could fail. At first you might think, that raising an exception would be
a good fit for such a failure. It is not. A lot of the time, we are mapping user
input to objects, and users need to hear better error messages than "Something
went wrong" or "Hey, you cannot be born in the future". Of course the second
version is a step in the right direction, but for efficiency reasons, the user
would like hear everything, that is wrong in his input, all at once. Therefore
errors have to be accumulated through the whole process. We implement that by
returning `JM::Result`s instead of returning values or raising
exceptions. Normal return values are wrapped in `JM::Success` while errors are
wrapped in a `JM::Failure`. Then throughout the whole mapping process, failures
are merged and can be returned to the user/client.

For example, we could read the `age` property of a hash.

```ruby
def age(person)
  if person.key?("age")
    JM::Success.new(person["age"])
  else
    JM::Failure.new(JM::Error.new(["age"], :required))
  end
end
```

A failure can be initialized with an error or an array of errors. And an error
takes three parameters:

- A path into the data structure. If you were mapping an array of numbers and
  the 5th one was faulty, the path would reflect that. The path would be
  `[4]`. Paths can also have multiple elements to point into nested data
  structrues like `["data", :numbers, 4]`.
- A symbol to distinguish the error from other error types
- A hash of parameters

These three can later be used to generate error messages.

### Accessors

You pass an accessor, when you want to customize how to read from and write to
your object. Let's implement an accessor, that accesses the `name` property of
an object.

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

Mappers transform [values](http://en.wikipedia.org/wiki/Value_object). So you
pass a mapper, when you would like to transform a value during the mapping
process. You might for example want to serialize `Date` objects to a custom
format.

```ruby
class DateMapper < JM::Mapper
  def read(string)
    JM::Success.new(Date.rfc822(string))
  rescue ArgumentError
    JM::Failure.new(JM::Error.new([], :format))
  rescue TypeError
    JM::Failure.new(JM::Error.new([], :type))
  end

  def write(date)
    JM::Success.new(date.rfc822)
  end
end

mapper = DateMapper.new

mapper.write(Date.new(2014, 8, 13)).value
# => "Wed, 13 Aug 2014 00:00:00 +0000"

mapper.read("Wed, 13 Aug 2014 00:00:00 +0000").value
# => #<Date: 2014-08-13 ((2456883j,0s,0n),+0s,2299161j)>

mapper.read("Not a date").errors
# => [#<JM::Error:0x0055ba2943ea98 @name=:format, @params={}, @path=[]>]
```

### Syncers

Defining a custom syncer is a very general way of synchronizing data between two
formats. Most commonly one is a ruby object and another is a parsed JSON value,
normally a JSON object.

```ruby
Person = Struct.new(:name, :age)

class PersonSyncer < JM::Syncer
  def push(person, hash, *args)
    hash[:name] = person.name
    hash[:info] ||= {}
    hash[:info][:age] = person.age

    JM::Success.new(hash)
  end

  def pull(person, hash, *args)
    person.name = hash[:name]
    person.age = hash[:info][:age]

    JM::Success.new(person)
  end
end

syncer = PersonSyncer.new
person = Person.new("Gandalf", 513)
hash = {}

syncer.push(person, hash)
hash
# => {:name=>"Gandalf", :info=>{:age=>513}}

syncer.pull(person, {name: "Frodo", info: {age: 50}})
person
# => #<struct Person name="Frodo", age=50>
```

## Documentation

You can find the DSL documentation directly
[in the code](lib/jm/dsl). Alternatively you can execute the following shell
script to generate the docs and view them
[in your browser](http://localhost:8000).

```sh
cd <jm project root>

bundle exec yardoc lib

cd doc

python -m http.server -p 8000
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
