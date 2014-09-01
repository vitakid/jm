describe JM::Results::ArrayReducer do
  let(:reducer) { JM::Results::ArrayReducer.new }

  it "should reduce an array of successes to a success with an array value" do
    successes = [JM::Success.new(1), JM::Success.new("two")]

    expect(reducer.reduce(successes)).to succeed_with([1, "two"])
  end

  it "should combine failures" do
    failures = (0..1).to_a.map do
      JM::Failure.new(JM::Error.new([], :fail))
    end

    errors = [JM::Error.new([0], :fail), JM::Error.new([1], :fail)]
    expect(reducer.reduce(failures)).to fail_with(errors)
  end

  it "should fail when at least one of the results is a failure" do
    results = [
      JM::Success.new(1),
      JM::Failure.new(JM::Error.new([], :error)),
      JM::Success.new(true)
    ]

    expect(reducer.reduce(results)).to fail_with([JM::Error.new([1], :error)])
  end
end
