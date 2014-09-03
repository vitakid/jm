RSpec::Matchers.define :succeed_with do |expected|
  match do |actual|
    actual.is_a?(JM::Success) && actual.value == expected
  end

  failure_message do |actual|
    if actual.is_a?(JM::Failure)
      "expected it to succeed, but it failed with #{actual.errors.inspect}"
    elsif actual.is_a?(JM::Success)
      "expected it to succeed with #{expected.inspect}, but it succeeded " \
        "with #{actual.value.inspect}"
    else
      "expected it to succeed with #{expected.inspect}, but got " +
        actual.inspect
    end
  end
end
