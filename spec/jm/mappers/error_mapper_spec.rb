describe JM::Mappers::ErrorMapper do
  let(:mapper) { JM::Mappers::ErrorMapper.new }

  describe "Adding messages" do
    before(:each) do
      @backend = I18n.backend
      I18n.backend = I18n::Backend::HashBackend.new
    end

    after(:each) do
      I18n.backend = @backend
    end

    it "should add a nil 'messages' key, if there is no translation" do
      error = JM::Error.new([], :invalid)

      result = mapper.write(error)

      expected = {
        "path" => [], "name" => :invalid, "message" => nil
      }
      expect(result).to succeed_with(expected)
    end

    it "should look in 'jm.errors' for messages" do
      error = JM::Error.new([], :invalid)
      I18n.backend["jm.errors.invalid"] = "Invalid data"

      result = mapper.write(error)

      expected = {
        "path" => [], "name" => :invalid, "message" => "Invalid data"
      }
      expect(result).to succeed_with(expected)
    end

    it "should look in 'jm.errors.<path>' for a translation" do
      error = JM::Error.new(%w(nested path), :invalid)
      I18n.backend["jm.errors.nested.path.invalid"] = "Not valid"

      result = mapper.write(error)

      expected = {
        "path" => %w(nested path),
        "name" => :invalid,
        "message" => "Not valid"
      }
      expect(result).to succeed_with(expected)
    end

    it "should strip of parts of the path until it finds a translation" do
      error = JM::Error.new(%w(nested path), :invalid)
      I18n.backend["jm.errors.invalid"] = "Not valid"

      result = mapper.write(error)

      expected = {
        "path" => %w(nested path),
        "name" => :invalid,
        "message" => "Not valid"
      }
      expect(result).to succeed_with(expected)
    end

    it "should prefer more specific i18n paths" do
      error = JM::Error.new(%w(nested path), :invalid)
      I18n.backend["jm.errors.invalid"] = "Generally bad"
      I18n.backend["jm.errors.path.invalid"] = "Specifically bad"

      result = mapper.write(error)

      expected = {
        "path" => %w(nested path),
        "name" => :invalid,
        "message" => "Specifically bad"
      }
      expect(result).to succeed_with(expected)
    end

    it "should pass the error params to the translations" do
      error = JM::Error.new(%w(person age), :too_young, age: 5)
      I18n.backend["jm.errors.too_young"] = "%{age} is too young"

      result = mapper.write(error)

      expected = {
        "path" => %w(person age),
        "name" => :too_young,
        "message" => "5 is too young"
      }
      expect(result).to succeed_with(expected)
    end

    it "should use the gem-owned translations" do
      I18n.backend = @backend
      error = JM::Errors::DateISO8601IncompatibleError.new([], "not-compatible")

      result = mapper.write(error)

      expected = {
        "path" => [],
        "name" => :date_iso8601_incompatible,
        "message" => "\"not-compatible\" is no ISO8601 compatible date"
      }
      expect(result).to succeed_with(expected)
    end
  end
end
