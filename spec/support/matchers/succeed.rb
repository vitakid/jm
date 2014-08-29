RSpec::Matchers.define :succeed do
  match do |actual|
    actual.is_a?(JM::Success)
  end

  failure_message do
    "expected it to succeed"
  end
end
