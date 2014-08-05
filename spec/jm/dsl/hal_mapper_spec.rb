describe JM::DSL::HALMapper do
  let(:pet_class) do
    Struct.new(:name)
  end

  let(:pet_mapper) do
    pet = pet_class

    Class.new(JM::DSL::HALMapper) do
      define_method(:initialize) do
        super(pet)

        link :self, "/pets/{name}"

        property :name
      end
    end
  end

  let(:person_class) do
    Struct.new(:first_name, :last_name, :age)
  end

  context "when mapping a resource with 'self' link" do
    let(:mapper_class) do
      person = person_class

      Class.new(JM::DSL::HALMapper) do
        define_method(:initialize) do
          super(person)

          link :self, "/people/{name}" do
            define_method(:set) do |p, params|
              first_name, last_name = params["name"].split("-")

              p.first_name = first_name.capitalize
              p.last_name = last_name.capitalize
            end

            def get(p)
              name = "#{p.first_name.downcase}-#{p.last_name.downcase}"

              { name: name }
            end
          end

          property :age
        end
      end
    end

    context "to a hash" do
      it "should generate a self link" do
        person = person_class.new("Marten", "Lienen", 21)

        hash = mapper_class.new.write(person)

        expect(hash).to eq(_links: { self: { href: "/people/marten-lienen" } },
                           age: 21)
      end
    end

    context "from a hash" do
      it "should instantiate the object from the URI" do
        hash = { _links: { self: { href: "/people/marten-lienen" } },
                 age: 21 }

        person = mapper_class.new.read(hash)

        expect(person).to eq(person_class.new("Marten", "Lienen", 21))
      end
    end
  end

  context "when mapping a resource without a 'self' link" do
    let(:mapper_class) do
      person = person_class

      Class.new(JM::DSL::HALMapper) do
        define_method(:initialize) do
          super(person)

          property :age
        end
      end
    end

    context "to a hash" do
      it "should make no difference" do
        person = person_class.new("Marten", "Lienen", 21)

        hash = mapper_class.new.write(person)

        expect(hash).to eq(age: 21)
      end
    end

    context "from a hash" do
      it "should still instantiate the correct class" do
        hash = { age: 21 }

        person = mapper_class.new.read(hash)

        expect(person).to eq(person_class.new(nil, nil, 21))
      end
    end
  end

  context "when linking to another 'self' linked entity" do
    let(:person_class) do
      Struct.new(:name, :pet)
    end

    let(:person_mapper) do
      pet_m = pet_mapper
      person = person_class

      Class.new(JM::DSL::HALMapper) do
        define_method(:initialize) do
          super(person)

          link :pet, pet_m.new do
            def set(person, pet)
              person.pet = pet
            end

            def get(person)
              person.pet
            end
          end

          property :name
        end
      end
    end

    context "and mapping to a hash" do
      it "should use the mapper's 'self' link pipe" do
        person = person_class.new("Frodo", pet_class.new("Finchen"))

        hash = person_mapper.new.write(person)

        expect(hash).to eq(_links: { pet: { href: "/pets/Finchen" } },
                           name: "Frodo")
      end
    end

    context "and mapping from a hash" do
      it "should instantiate the object from the link" do
        hash = { _links: { pet: { href: "/pets/Finchen" } },
                 name: "Frodo" }

        person = person_mapper.new.read(hash)

        expect(person).to eq(person_class.new("Frodo",
                                              pet_class.new("Finchen")))
      end
    end
  end

  context "when mapping a 'self' as well as another link" do
    let(:person_class) do
      Struct.new(:name, :pet)
    end

    let(:person_mapper) do
      pet_m = pet_mapper
      person = person_class

      Class.new(JM::DSL::HALMapper) do
        define_method(:initialize) do
          super(person)

          link :self, "/people/{name}"

          link :pet,
               pet_m.new,
               accessor: JM::Accessors::AccessorAccessor.new(:pet)
        end
      end
    end

    context "to a hash" do
      it "should create both links" do
        person = person_class.new("Marten", pet_class.new("Ronja"))

        hash = person_mapper.new.write(person)

        expect(hash).to eq(_links: { self: { href: "/people/Marten" },
                                     pet: { href: "/pets/Ronja" } })
      end
    end

    context "from a hash" do
      it "should parse both links" do
        hash = { _links: { self: { href: "/people/Marten" },
                           pet: { href: "/pets/Ronja" } } }

        person = person_mapper.new.read(hash)

        expect(person).to eq(person_class.new("Marten", pet_class.new("Ronja")))
      end
    end
  end

  context "when mapping an array of links" do
    let(:person_class) do
      Struct.new(:name, :pets)
    end

    let(:person_mapper) do
      person = person_class
      pet_m = pet_mapper

      Class.new(JM::DSL::HALMapper) do
        define_method(:initialize) do
          super(person)

          links :pet,
                pet_m.new,
                accessor: JM::Accessors::AccessorAccessor.new(:pets)
        end
      end
    end

    context "to a hash" do
      it "should generate a HAL link array" do
        person = person_class.new("Marten", [pet_class.new("Finchen"),
                                             pet_class.new("Ronja")])

        hash = person_mapper.new.write(person)

        expect(hash).to eq(_links: { pet: [{ href: "/pets/Finchen" },
                                           { href: "/pets/Ronja" }] })
      end
    end

    context "from a hash" do
      it "should map all links to objects" do
        hash = { _links: { pet: [{ href: "/pets/Finchen" },
                                 { href: "/pets/Ronja" }] } }

        person = person_mapper.new.read(hash)

        expect(person).to eq(person_class.new(nil, [pet_class.new("Finchen"),
                                                    pet_class.new("Ronja")]))
      end
    end
  end

  context "when mapping an embedded resource" do
    let(:person_class) do
      Struct.new(:name, :pet)
    end

    let(:person_mapper) do
      pet_m = pet_mapper
      person = person_class

      Class.new(JM::DSL::HALMapper) do
        define_method(:initialize) do
          super(person)

          embedded :pet, pet_m.new

          property :name
        end
      end
    end

    context "to a hash" do
      it "should embed the pet" do
        person = person_class.new("Marten", pet_class.new("Finchen"))

        hash = person_mapper.new.write(person)

        expect(hash).to eq(_embedded: {
                             pet: {
                               _links: { self: { href: "/pets/Finchen" } },
                               name: "Finchen"
                             }
                           },
                           name: "Marten")
      end
    end

    context "from a hash" do
      it "should read the embedded pet" do
        hash = { _embedded: {
          pet: {
            _links: { self: { href: "/pets/Finchen" } },
            name: "Finchen"
          }
        },
                 name: "Marten" }

        person = person_mapper.new.read(hash)

        expected = person_class.new("Marten", pet_class.new("Finchen"))
        expect(person).to eq(expected)
      end
    end
  end

  context "when mapping multiple embedded resources" do
    let(:person_class) do
      Struct.new(:name, :pets)
    end

    let(:person_mapper) do
      pet_m = pet_mapper
      person = person_class

      Class.new(JM::DSL::HALMapper) do
        define_method(:initialize) do
          super(person)

          embeddeds :pets, pet_m.new

          property :name
        end
      end
    end

    context "to a hash" do
      it "should embed the pets" do
        person = person_class.new("Marten", [pet_class.new("Finchen"),
                                             pet_class.new("Ronja")])

        hash = person_mapper.new.write(person)

        expect(hash).to eq(_embedded: {
                             pets: [
                               {
                                 _links: { self: { href: "/pets/Finchen" } },
                                 name: "Finchen"
                               },
                               {
                                 _links: { self: { href: "/pets/Ronja" } },
                                 name: "Ronja"
                               }
                             ]
                           },
                           name: "Marten")
      end
    end

    context "from a hash" do
      it "should read the embedded pet" do
        hash = { _embedded: {
          pets: [
            {
              _links: { self: { href: "/pets/Finchen" } },
              name: "Finchen"
            },
            {
              _links: { self: { href: "/pets/Ronja" } },
              name: "Ronja"
            }
          ]
        },
                 name: "Marten" }

        person = person_mapper.new.read(hash)

        expected = person_class.new("Marten", [pet_class.new("Finchen"),
                                               pet_class.new("Ronja")])
        expect(person).to eq(expected)
      end
    end
  end
end
