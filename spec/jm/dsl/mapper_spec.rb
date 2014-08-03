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

  context "when mapping from a hash" do
    it "should map keys to properties" do
      hash = { first_name: "Marten", last_name: "Lienen" }
      person = mapper.write(self.class.new, hash)

      expect(person).to eq(self.class.new("Marten", "Lienen"))
    end
  end
end
