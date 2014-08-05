describe JM::DSL::Mapper do
  context "when mapping simple properties" do
    let(:mapper) do
      person_class = person

      Class.new(JM::DSL::Mapper) do
        define_method(:initialize) do
          super(person_class, Hash)
        end

        property :first_name
        property :last_name
      end
    end

    let(:person) do
      Struct.new(:first_name, :last_name)
    end

    context "when mapping to a hash" do
      it "should map properties to keys" do
        p = person.new("Marten", "Lienen")

        hash = mapper.new.write(p)

        expect(hash).to eq(first_name: "Marten", last_name: "Lienen")
      end
    end

    context "when mapping from a hash" do
      it "should map keys to properties" do
        hash = { first_name: "Marten", last_name: "Lienen" }

        p = mapper.new.read(hash)

        expect(p).to eq(person.new("Marten", "Lienen"))
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
          super(person, Hash)
        end

        property :name

        property :age, read_only: true
      end
    end

    it "should write the property" do
      person = person_class.new("Frodo", 50)

      hash = person_mapper.new.write(person)

      expect(hash).to eq(name: "Frodo", age: 50)
    end

    it "should not read the property" do
      hash = { name: "Frodo", age: 50 }

      person = person_mapper.new.read(hash)

      expect(person).to eq(person_class.new("Frodo", nil))
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
          super(person, Hash)
        end

        property :name

        property :age,
                 write_if: -> p { p.age > 18 },
                 read_if: -> p { p[:age] < 18 }
      end
    end

    context "to a hash" do
      it "should write the property, if the condition holds" do
        person = person_class.new("Marten", 21)

        hash = person_mapper.new.write(person)

        expect(hash).to eq(name: "Marten", age: 21)
      end

      it "should not write the property, if the condition fails" do
        person = person_class.new("Alex", 7)

        hash = person_mapper.new.write(person)

        expect(hash).to eq(name: "Alex")
      end
    end

    context "from a hash" do
      it "should read the property, if the condition holds" do
        hash = { name: "Alex", age: 14 }

        person = person_mapper.new.read(hash)

        expect(person).to eq(person_class.new("Alex", 14))
      end

      it "should not read the property, if the condition fails" do
        hash = { name: "Marten", age: 21 }

        person = person_mapper.new.read(hash)

        expect(person).to eq(person_class.new("Marten", nil))
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
          super(person, Hash)
        end

        read_only_property :name do |p|
          "#{p.name}, #{p.age}"
        end
      end
    end

    it "should write normally" do
      person = person_class.new("Marten", 21)

      hash = person_mapper.new.write(person)

      expect(hash).to eq(name: "Marten, 21")
    end

    it "should be read-only" do
      hash = { name: "Marten, 21" }

      person = person_mapper.new.read(hash)

      expect(person).to eq(person_class.new(nil, nil))
    end
  end

  context "when mapping a complex property with an inline accessor" do
    let(:person_class) do
      Struct.new(:name, :age)
    end

    let(:person_mapper) do
      person = person_class

      Class.new(JM::DSL::Mapper) do
        define_method(:initialize) do
          super(person, Hash)
        end

        property :name do
          def get(person)
            "#{person.name} (#{person.age})"
          end

          def set(person, value)
            name, age = /(.+) \(([0-9]+)\)/.match(value).captures

            person.name = name
            person.age = age.to_i
          end
        end
      end
    end

    context "to a hash" do
      it "should use the inline accessor" do
        person = person_class.new("James", 49)

        hash = person_mapper.new.write(person)

        expect(hash).to eq(name: "James (49)")
      end
    end

    context "from a hash" do
      it "should use the inline accessor" do
        hash = { name: "James (49)" }

        person = person_mapper.new.read(hash)

        expect(person).to eq(person_class.new("James", 49))
      end
    end
  end

  context "when mapping arrays" do
    let(:person_mapper) do
      person_class = person

      Class.new(JM::DSL::Mapper) do
        define_method(:initialize) do
          super(person_class, Hash)
        end

        property :name
      end
    end

    let(:mapper) do
      community_class = community
      m = person_mapper.new

      Class.new(JM::DSL::Mapper) do
        define_method(:initialize) do
          super(community_class, Hash)
        end

        array :people, m
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

        expect(hash).to eq(people: [{ name: "Marten" }, { name: "Lienen" }])
      end
    end

    context "from a hash" do
      it "should correctly deserialize them" do
        hash = { people: [{ name: "Marten" }, { name: "Lienen" }] }

        comm = mapper.new.read(hash)

        expect(comm).to eq(community.new([person.new("Marten"),
                                          person.new("Lienen")]))
      end
    end
  end
end
