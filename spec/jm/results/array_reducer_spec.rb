describe JM::Results::ArrayReducer do
  let(:reducer) { JM::Results::ArrayReducer.new }

  it "should reduce an array of successes to a success with an array value" do
    successes = [JM::Success.new(1), JM::Success.new("two")]

    expect(reducer.reduce(successes)).to succeed_with([1, "two"])
  end

  it "should combine failures" do
    errors = [
      JM::Error.new(:first),
      JM::Error.new(:second)
    ]

    failures = errors.map { |e| JM::Failure.new(e) }

    expect(reducer.reduce(failures)).to fail_with(errors)
  end

  it "should fail when at least one of the results is a failure" do
    results = [
      JM::Success.new(1),
      JM::Failure.new(JM::Error.new(:error)),
      JM::Success.new(true)
    ]

    expect(reducer.reduce(results)).to fail_with([JM::Error.new(:error)])
  end
end
