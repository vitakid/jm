require "json"

describe JM::Failure do
  before(:each) do
    @backend = I18n.backend
    I18n.backend = I18n::Backend::HashBackend.new
  end

  after(:each) do
    I18n.backend = @backend
  end

  it "should be convertible to JSON" do
    error = JM::Error.new(["people", 2, "age"], :too_young, age: 14)
    failure = JM::Failure.new(error)
    I18n.backend["jm.errors.age.too_young"] = "%{age} is too young"

    json = failure.to_json

    expected = {
      "errors" => [
        {
          "path" => ["people", 2, "age"],
          "name" => "too_young",
          "message" => "14 is too young"
        }
      ]
    }
    expect(JSON.parse(json)).to eq(expected)
  end
end
