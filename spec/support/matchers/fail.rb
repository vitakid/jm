RSpec::Matchers.define :fail do
  match do |actual|
    actual.is_a?(JM::Failure)
  end

  failure_message do
    "expected it to fail"
  end
end
