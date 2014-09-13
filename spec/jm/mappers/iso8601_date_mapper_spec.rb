describe JM::Mappers::ISO8601DateMapper do
  let(:mapper) { JM::Mappers::ISO8601DateMapper.new }

  it "should map Date objects to ISO8601 strings" do
    expect(mapper.write(Date.new(2014, 9, 12))).to succeed_with("2014-09-12")
  end

  it "should map ISO8601 strings to Date objects" do
    expect(mapper.read("2014-09-12")).to succeed_with(Date.new(2014, 9, 12))
  end

  it "should fail, when the date string is invalid" do
    errors = JM::Errors::DateISO8601IncompatibleError.new([])
    expect(mapper.read("not-a-date")).to fail_with(errors)
  end
end
