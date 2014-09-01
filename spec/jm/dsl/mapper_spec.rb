describe JM::DSL::Mapper do
  context "when mapping simple properties" do
    let(:mapper) do
      person_class = person

      Class.new(JM::DSL::Mapper) do
        define_method(:initialize) do
          super(JM::Mappers::InstanceMapper.new(person_class, Hash))

          property :first_name
          property :last_name
        end
      end
    end

    let(:person) do
      Struct.new(:first_name, :last_name)
    end

    context "to a hash" do
      it "should map properties to keys" do
        p = person.new("Marten", "Lienen")

        hash = mapper.new.write(p)

        expect(hash).to succeed_with(first_name: "Marten", last_name: "Lienen")
      end
    end

    context "from a hash" do
      it "should map keys to properties" do
        hash = { first_name: "Marten", last_name: "Lienen" }

        p = mapper.new.read(hash)

        expect(p).to succeed_with(person.new("Marten", "Lienen"))
      end
    end
  end

  context "when mapping a read-only property" do
    let(:person_class) do
      Struct.new(:name, :age)
    end

    let(:person_mapper) do
      person = person_class

      Class.new(JM::DSL::Mapper) do
        define_method(:initialize) do
          super(JM::Mappers::InstanceMapper.new(person, Hash))

          property :name

          property :age, read_only: true
        end
      end
    end

    it "should write the property" do
      person = person_class.new("Frodo", 50)

      hash = person_mapper.new.write(person)

      expect(hash).to succeed_with(name: "Frodo", age: 50)
    end

    it "should not read the property" do
      hash = { name: "Frodo", age: 50 }

      person = person_mapper.new.read(hash)

      expect(person).to succeed_with(person_class.new("Frodo", nil))
    end
  end

  context "when mapping a property conditionally" do
    let(:person_class) do
      Struct.new(:name, :age)
    end

    let(:person_mapper) do
      person = person_class

      Class.new(JM::DSL::Mapper) do
        define_method(:initialize) do
          super(JM::Mappers::InstanceMapper.new(person, Hash))

          property :name

          property :age,
                   write_if: -> p { p.age > 18 },
                   read_if: -> p { p[:age] < 18 }
        end
      end
    end

    context "to a hash" do
      it "should write the property, if the condition holds" do
        person = person_class.new("Marten", 21)

        hash = person_mapper.new.write(person)

        expect(hash).to succeed_with(name: "Marten", age: 21)
      end

      it "should not write the property, if the condition fails" do
        person = person_class.new("Alex", 7)

        hash = person_mapper.new.write(person)

        expect(hash).to succeed_with(name: "Alex")
      end
    end

    context "from a hash" do
      it "should read the property, if the condition holds" do
        hash = { name: "Alex", age: 14 }

        person = person_mapper.new.read(hash)

        expect(person).to succeed_with(person_class.new("Alex", 14))
      end

      it "should not read the property, if the condition fails" do
        hash = { name: "Marten", age: 21 }

        person = person_mapper.new.read(hash)

        expect(person).to succeed_with(person_class.new("Marten", nil))
      end
    end
  end

  context "when using the #read_only_property shorthand" do
    let(:person_class) do
      Struct.new(:name, :age)
    end

    let(:person_mapper) do
      person = person_class

      Class.new(JM::DSL::Mapper) do
        define_method(:initialize) do
          super(JM::Mappers::InstanceMapper.new(person, Hash))

          read_only_property :name do |p|
            "#{p.name}, #{p.age}"
          end
        end
      end
    end

    it "should write normally" do
      person = person_class.new("Marten", 21)

      hash = person_mapper.new.write(person)

      expect(hash).to succeed_with(name: "Marten, 21")
    end

    it "should be read-only" do
      hash = { name: "Marten, 21" }

      person = person_mapper.new.read(hash)

      expect(person).to succeed_with(person_class.new(nil, nil))
    end
  end

  context "when mapping a complex property with an inline accessor" do
    let(:person_class) do
      Struct.new(:name, :age)
    end

    let(:person_mapper) do
      person_cls = person_class

      Class.new(JM::DSL::Mapper) do
        define_method(:initialize) do
          super(JM::Mappers::InstanceMapper.new(person_cls, Hash))

          property :name do
            get do |person|
              "#{person.name} (#{person.age})"
            end

            set do |person, value|
              name, age = /(.+) \(([0-9]+)\)/.match(value).captures

              person.name = name
              person.age = age.to_i

              person
            end
          end
        end
      end
    end

    context "to a hash" do
      it "should use the inline accessor" do
        person = person_class.new("James", 49)

        hash = person_mapper.new.write(person)

        expect(hash).to succeed_with(name: "James (49)")
      end
    end

    context "from a hash" do
      it "should use the inline accessor" do
        hash = { name: "James (49)" }

        person = person_mapper.new.read(hash)

        expect(person).to succeed_with(person_class.new("James", 49))
      end
    end
  end

  context "when mapping arrays" do
    let(:person_mapper) do
      person_class = person

      Class.new(JM::DSL::Mapper) do
        define_method(:initialize) do
          super(JM::Mappers::InstanceMapper.new(person_class, Hash))

          property :name
        end
      end
    end

    let(:mapper) do
      community_class = community
      m = person_mapper.new

      Class.new(JM::DSL::Mapper) do
        define_method(:initialize) do
          super(JM::Mappers::InstanceMapper.new(community_class, Hash))

          array :people, m
        end
      end
    end

    let(:community) do
      Struct.new(:people)
    end

    let(:person) do
      Struct.new(:name)
    end

    context "to a hash" do
      it "should correctly serialize them" do
        comm = community.new([person.new("Marten"), person.new("Lienen")])

        hash = mapper.new.write(comm)

        expect(hash).to succeed_with(people: [{ name: "Marten" },
                                              { name: "Lienen" }])
      end
    end

    context "from a hash" do
      it "should correctly deserialize them" do
        hash = { people: [{ name: "Marten" }, { name: "Lienen" }] }

        comm = mapper.new.read(hash)

        expect(comm).to succeed_with(community.new([person.new("Marten"),
                                                    person.new("Lienen")]))
      end
    end

    it "should be possible to define a custom accessor with a block" do
      person_m = person_mapper.new
      person_class = person
      m = Class.new(JM::DSL::Mapper) do
        define_method(:initialize) do
          super(JM::Mappers::InstanceMapper.new(person_class, Hash))

          array :persons, person_m do
            get do |community|
              community.people
            end
          end
        end
      end

      community_mapper = m.new
      c = community.new([person.new("A")])

      hash = community_mapper.write(c)

      expect(hash).to succeed_with(persons: [{ name: "A" }])
    end
  end
end
