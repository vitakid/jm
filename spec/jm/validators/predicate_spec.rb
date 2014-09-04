describe JM::Validators::Predicate do
  let(:predicate_class) do
    Class.new(JM::Validators::Predicate) do
      def initialize
        super(JM::Error.new([], :too_small, limit: 5)) do |object|
          object > 5
        end
      end
    end
  end

  let(:predicate) { predicate_class.new }

  it "should succeed if the predicate is true" do
    expect(predicate.validate(10)).to succeed_with(10)
  end

  it "should fail if the predicate is false" do
    error = JM::Error.new([], :too_small, limit: 5)
    expect(predicate.validate(3)).to fail_with(error)
  end
end
