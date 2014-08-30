describe JM::Mappers::MapperChain do
  let(:plus_one_mapper) do
    Class.new(JM::Mapper) do
      def write(value)
        JM::Success.new(value + 1)
      end

      def read(value)
        JM::Success.new(value - 1)
      end
    end
  end

  let(:failing_mapper) do
    Class.new(JM::Mapper) do
      def write(value)
        JM::Failure.new(JM::Error.new(:fail))
      end

      def read(value)
        JM::Failure.new(JM::Error.new(:fail))
      end
    end
  end

  describe "#read" do
    it "should succeed with the chained result" do
      chain = JM::Mappers::MapperChain.new(
        [
          plus_one_mapper.new,
          plus_one_mapper.new
        ]
      )

      expect(chain.read(5)).to succeed_with(3)
    end

    it "should fail with the first failure" do
      chain = JM::Mappers::MapperChain.new(
        [
          plus_one_mapper.new,
          failing_mapper.new,
          plus_one_mapper.new
        ]
      )

      expect(chain.read(5)).to fail_with(JM::Error.new(:fail))
    end
  end

  describe "#write" do
    it "should succeed with the chained result" do
      chain = JM::Mappers::MapperChain.new(
        [
          plus_one_mapper.new,
          plus_one_mapper.new
        ]
      )

      expect(chain.write(5)).to succeed_with(7)
    end

    it "should fail with the first failure" do
      chain = JM::Mappers::MapperChain.new(
        [
          plus_one_mapper.new,
          failing_mapper.new,
          plus_one_mapper.new
        ]
      )

      expect(chain.write(5)).to fail_with(JM::Error.new(:fail))
    end
  end
end
