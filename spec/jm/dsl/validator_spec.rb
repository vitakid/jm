RSpec.shared_examples "a validator DSL" do
  let(:dsl) { -> {} }

  let(:validator) do
    block = dsl

    Class.new(JM::DSL::Validator) do
      define_method(:initialize) do
        super()

        instance_exec(&block)
      end
    end
  end

  it "should succeed, when the input is valid" do
    result = validator.new.validate(valid)

    expect(result).to succeed_with(valid)
  end

  it "should fail, when the input is invalid" do
    result = validator.new.validate(invalid)

    expect(result).to fail_with(error)
  end
end

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
    it_behaves_like "a validator DSL" do
      let(:dsl) do
        lambda do
          inline do |value|
            if value > 10
              JM::Success.new(value)
            else
              JM::Failure.new(JM::Error.new([], :fail))
            end
          end
        end
      end

      let(:valid) { 20 }
      let(:invalid) { 1 }
      let(:error) { JM::Error.new([], :fail) }
    end
  end

  context "with an inline predicate" do
    it_behaves_like "a validator DSL" do
      let(:dsl) do
        lambda do
          predicate(JM::Error.new([], :too_short)) do |string|
            string.length > 5
          end
        end
      end

      let(:valid) { "recursion" }
      let(:invalid) { "ruby" }
      let(:error) { JM::Error.new([], :too_short) }
    end
  end

  context "when validating with a regexp" do
    it_behaves_like "a validator DSL" do
      let(:dsl) { -> { regexp(/\A[0-9]-[a-r]\Z/) } }
      let(:valid) { "1-g" }
      let(:invalid) { "1-00" }
      let(:error) { JM::Errors::NoRegexpMatchError.new([], /\A[0-9]-[a-r]\Z/) }
    end
  end
end
