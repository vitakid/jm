describe JM::DSL::Mapper do
  let(:mapper) do
    Class.new(JM::DSL::Mapper) do
      property :first_name
      property :last_name
    end.new
  end

  let(:class) do
    Struct.new(:first_name, :last_name)
  end

  let(:person) do
    self.class.new("Marten", "Lienen")
  end

  context "when mapping to a hash" do
    it "should map properties to keys" do
      hash = mapper.read(person)

      expect(hash).to eq(first_name: "Marten", last_name: "Lienen")
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
