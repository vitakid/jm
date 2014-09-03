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

  describe "#inline" do
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
end
