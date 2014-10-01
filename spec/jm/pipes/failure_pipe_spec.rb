describe JM::Pipes::FailurePipe do
  let(:pipe) { JM::Pipes::FailurePipe.new }

  before(:each) do
    @backend = I18n.backend
    I18n.backend = I18n::Backend::HashBackend.new
  end

  after(:each) do
    I18n.backend = @backend
  end

  it "should map failures to JSON" do
    failure = JM::Failure.new(JM::Error.new([:nested, 0, :attribute], :invalid))
    I18n.backend["jm.errors.invalid"] = "Invalid"

    result = pipe.pump(failure, {})

    expected = {
      "errors" => [
        {
          "path" => [:nested, 0, :attribute],
          "name" => :invalid,
          "message" => "Invalid"
        }
      ]
    }
    expect(result).to succeed_with(expected)
  end
end
