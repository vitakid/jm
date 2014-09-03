RSpec::Matchers.define :fail_with do |expected|
  match do |actual|
    actual.is_a?(JM::Failure) && actual.errors == Array(expected)
  end

  failure_message do |actual|
    if actual.is_a?(JM::Success)
      "expected it to fail, but it succeeded with #{actual.value.inspect}"
    elsif actual.is_a?(JM::Failure)
      "expected it to fail with #{expected.inspect}, but it failed with " +
        actual.errors.inspect
    else
      "expected it to fail with #{expected.inspect}, but got #{actual.inspect}"
    end
  end
end
