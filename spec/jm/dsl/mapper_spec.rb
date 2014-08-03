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

  context "when composing custom mappers" do
  end
end
