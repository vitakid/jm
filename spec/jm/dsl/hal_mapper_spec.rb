describe JM::DSL::HALMapper do
  let(:person_class) do
    Struct.new(:first_name, :last_name, :age)
  end

  context "when mapping a resource with 'self' link" do
    let(:mapper_class) do
      person = person_class

      Class.new(JM::DSL::HALMapper) do
        define_method(:initialize) do
          super(person, Hash)
        end

        link :self, "/people/{name}" do
          define_method(:read) do |params|
            first_name, last_name = params["name"].split("-")

            person.new(first_name.capitalize, last_name.capitalize)
          end

          def write(person)
            name = "#{person.first_name.downcase}-#{person.last_name.downcase}"

            { name: name }
          end
        end

        property :age
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
          super(person, Hash)
        end

        property :age
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
end
