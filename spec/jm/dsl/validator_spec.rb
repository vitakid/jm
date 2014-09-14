describe JM::DSL::Validator do
  describe "registering validators with #validator" do
    it "should register validators" do
      two_validator = Class.new(JM::Validator) do
        def validate(object)
          JM::Success.new(2)
        end
      end

      validator = Class.new(JM::DSL::Validator) do
        define_method(:initialize) do
          super()

          validator(two_validator.new)
        end
      end

      expect(validator.new.validate(10)).to succeed_with(2)
    end
  end

  context "with an inline validator" do
    let(:validator) do
      Class.new(JM::DSL::Validator) do
        def initialize
          super

          inline do |value|
            if value > 10
              JM::Success.new(value)
            else
              JM::Failure.new(JM::Error.new([], :fail))
            end
          end
        end
      end
    end

    it "should succeed, when the block succeeds" do
      expect(validator.new.validate(20)).to succeed_with(20)
    end

    it "should fail, when the block fails" do
      expect(validator.new.validate(1)).to fail_with(JM::Error.new([], :fail))
    end
  end

  context "with an inline predicate" do
    let(:validator) do
      Class.new(JM::DSL::Validator) do
        def initialize
          super

          predicate(JM::Error.new([], :too_short)) do |string|
            string.length > 5
          end
        end
      end
    end

    it "should succeed, when the predicate is true" do
      result = validator.new.validate("recursion")

      expect(result).to succeed_with("recursion")
    end

    it "should fail, when the predicate is false" do
      result = validator.new.validate("ruby")

      expect(result).to fail_with(JM::Error.new([], :too_short))
    end
  end

  context "when validating with a regexp" do
    let(:validator) do
      Class.new(JM::DSL::Validator) do
        def initialize
          super

          regexp /\A[0-9]-[a-r]\Z/
        end
      end
    end

    it "should succeed, when the regexp matches" do
      result = validator.new.validate("1-g")

      expect(result).to succeed_with("1-g")
    end

    it "should fail, when the regexp does not match" do
      result = validator.new.validate("1-00")

      error = JM::Errors::NoRegexpMatchError.new([], /\A[0-9]-[a-r]\Z/)
      expect(result).to fail_with(error)
    end
  end
end
