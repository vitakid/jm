describe JM::DSL::Syncer do
  context "when synchronizing simple properties" do
    let(:syncer) do
      Class.new(JM::DSL::Syncer) do
        define_method(:initialize) do
          super()

          property :first_name
          property :last_name
        end
      end
    end

    let(:person) do
      Struct.new(:first_name, :last_name)
    end

    context "to a hash" do
      it "should syncer properties to keys" do
        p = person.new("Marten", "Lienen")

        hash = syncer.new.push(p, {})

        expect(hash).to succeed_with(first_name: "Marten", last_name: "Lienen")
      end
    end

    context "from a hash" do
      it "should syncer keys to properties" do
        hash = { first_name: "Marten", last_name: "Lienen" }

        p = person.new
        result = syncer.new.pull(p, hash)

        expect(result).to succeed_with(person.new("Marten", "Lienen"))
      end
    end
  end

  context "when synchronizing a push-only property" do
    let(:person_class) do
      Struct.new(:name, :age)
    end

    let(:person_syncer) do
      Class.new(JM::DSL::Syncer) do
        define_method(:initialize) do
          super()

          property :name

          property :age, push_only: true
        end
      end
    end

    it "should push the property" do
      person = person_class.new("Frodo", 50)

      hash = person_syncer.new.push(person, {})

      expect(hash).to succeed_with(name: "Frodo", age: 50)
    end

    it "should not pull the property" do
      hash = { name: "Frodo", age: 50 }

      person = person_class.new
      result = person_syncer.new.pull(person, hash)

      expect(result).to succeed_with(person_class.new("Frodo", nil))
    end
  end

  context "when synchronizing a property conditionally" do
    let(:person_class) do
      Struct.new(:name, :age)
    end

    let(:person_syncer) do
      Class.new(JM::DSL::Syncer) do
        define_method(:initialize) do
          super()

          property :name

          property :age,
                   push_if: -> p, *_ { p.age > 18 },
                   pull_if: -> p, *_ { p[:age] < 18 }
        end
      end
    end

    context "to a hash" do
      it "should push the property, if the condition holds" do
        person = person_class.new("Marten", 21)

        hash = person_syncer.new.push(person, {})

        expect(hash).to succeed_with(name: "Marten", age: 21)
      end

      it "should not push the property, if the condition fails" do
        person = person_class.new("Alex", 7)

        hash = person_syncer.new.push(person, {})

        expect(hash).to succeed_with(name: "Alex")
      end
    end

    context "from a hash" do
      it "should pull the property, if the condition holds" do
        hash = { name: "Alex", age: 14 }

        result = person_syncer.new.pull(person_class.new, hash)

        expect(result).to succeed_with(person_class.new("Alex", 14))
      end

      it "should not pull the property, if the condition fails" do
        hash = { name: "Marten", age: 21 }

        result = person_syncer.new.pull(person_class.new, hash)

        expect(result).to succeed_with(person_class.new("Marten", nil))
      end
    end
  end

  context "when using the #push_only_property shorthand" do
    let(:person_class) do
      Struct.new(:name, :age)
    end

    let(:person_syncer) do
      Class.new(JM::DSL::Syncer) do
        define_method(:initialize) do
          super()

          push_only_property :name do |p|
            "#{p.name}, #{p.age}"
          end
        end
      end
    end

    it "should push normally" do
      person = person_class.new("Marten", 21)

      hash = person_syncer.new.push(person, {})

      expect(hash).to succeed_with(name: "Marten, 21")
    end

    it "should be push-only" do
      hash = { name: "Marten, 21" }

      result = person_syncer.new.pull(person_class.new, hash)

      expect(result).to succeed_with(person_class.new(nil, nil))
    end
  end

  context "when synchronizing a complex property with an inline accessor" do
    let(:person_class) do
      Struct.new(:name, :age)
    end

    let(:person_syncer) do
      Class.new(JM::DSL::Syncer) do
        define_method(:initialize) do
          super()

          property :name do
            get do |person|
              "#{person.name} (#{person.age})"
            end

            set do |person, value|
              name, age = /(.+) \(([0-9]+)\)/.match(value).captures

              person.name = name
              person.age = age.to_i

              person
            end
          end
        end
      end
    end

    context "to a hash" do
      it "should use the inline accessor" do
        person = person_class.new("James", 49)

        hash = person_syncer.new.push(person, {})

        expect(hash).to succeed_with(name: "James (49)")
      end
    end

    context "from a hash" do
      it "should use the inline accessor" do
        hash = { name: "James (49)" }

        result = person_syncer.new.pull(person_class.new, hash)

        expect(result).to succeed_with(person_class.new("James", 49))
      end
    end
  end

  context "when synchronizing arrays" do
    let(:person_syncer) do
      person_class = person

      Class.new(JM::DSL::Syncer) do
        define_method(:initialize) do
          super()

          self.source_factory = JM::Factories::NewFactory.new(person_class)
          self.target_factory = JM::Factories::NewFactory.new(Hash)

          property :name
        end
      end
    end

    let(:syncer) do
      m = person_syncer.new

      Class.new(JM::DSL::Syncer) do
        define_method(:initialize) do
          super()

          array :people, mapper: m.to_mapper
        end
      end
    end

    let(:community) do
      Struct.new(:people)
    end

    let(:person) do
      Struct.new(:name)
    end

    context "to a hash" do
      it "should correctly serialize them" do
        comm = community.new([person.new("Marten"), person.new("Lienen")])

        hash = syncer.new.push(comm, {})

        expect(hash).to succeed_with(people: [{ name: "Marten" },
                                              { name: "Lienen" }])
      end
    end

    context "from a hash" do
      it "should correctly deserialize them" do
        hash = { people: [{ name: "Marten" }, { name: "Lienen" }] }

        comm = syncer.new.pull(community.new, hash)

        expect(comm).to succeed_with(community.new([person.new("Marten"),
                                                    person.new("Lienen")]))
      end
    end

    it "should be possible to define a custom accessor with a block" do
      person_m = person_syncer.new

      m = Class.new(JM::DSL::Syncer) do
        define_method(:initialize) do
          super()

          array :persons, mapper: person_m.to_mapper do
            get(&:people)
          end
        end
      end

      community_syncer = m.new
      c = community.new([person.new("A")])

      hash = community_syncer.push(c, {})

      expect(hash).to succeed_with(persons: [{ name: "A" }])
    end
  end

  context "when synchronizing a validated property" do
    let(:person) do
      Struct.new(:name)
    end

    let(:person_syncer) do
      Class.new(JM::DSL::Syncer) do
        define_method(:initialize) do
          super()

          property :name do
            validator do
              inline do |name|
                if name.length < 5
                  JM::Failure.new(JM::Error.new([], :name_to_short))
                else
                  JM::Success.new(name)
                end
              end
            end
          end
        end
      end
    end

    context "from a hash" do
      it "should fail if the validation fails" do
        result = person_syncer.new.pull(person.new, name: "Sven")

        expect(result).to fail_with(JM::Error.new([:name], :name_to_short))
      end

      it "should succeed if the validation succeeds" do
        result = person_syncer.new.pull(person.new, name: "Marten")

        expect(result).to succeed_with(person.new("Marten"))
      end
    end

    context "to a hash" do
      it "should fail if the validation fails" do
        result = person_syncer.new.push(person.new("Sven"), {})

        expect(result).to fail_with(JM::Error.new([:name], :name_to_short))
      end

      it "should succeed if the validation succeeds" do
        result = person_syncer.new.push(person.new("Marten"), {})

        expect(result).to succeed_with(name: "Marten")
      end
    end
  end

  context "when synchronizing multiple validated properties" do
    let(:person) do
      Struct.new(:name, :age)
    end

    let(:person_syncer) do
      Class.new(JM::DSL::Syncer) do
        define_method(:initialize) do
          super()

          property :name do
            validator do
              inline do
                JM::Failure.new(JM::Error.new([], :too_short))
              end
            end
          end

          property :age do
            validator do
              inline do
                JM::Failure.new(JM::Error.new([], :not_born_yet))
              end
            end
          end
        end
      end
    end

    context "from a hash" do
      it "should merge all failures" do
        result = person_syncer.new.pull(person.new, name: "M", age: -1)

        expect(result).to fail_with([JM::Error.new([:name], :too_short),
                                     JM::Error.new([:age], :not_born_yet)])
      end
    end

    context "to a hash" do
      it "should merge all failures" do
        result = person_syncer.new.push(person.new("M", -1), {})

        expect(result).to fail_with([JM::Error.new([:name], :too_short),
                                     JM::Error.new([:age], :not_born_yet)])
      end
    end
  end

  context "when synchronizing an array property with validated elements" do
    let(:container) do
      Struct.new(:numbers)
    end

    let(:number_mapper) do
      Class.new(JM::Mapper) do
        def read(number)
          if (5..9).include?(number)
            JM::Failure.new(JM::Error.new([], :unwanted_number))
          else
            JM::Success.new(number)
          end
        end

        alias_method :write, :read
      end
    end

    let(:syncer) do
      number_m = number_mapper

      Class.new(JM::DSL::Syncer) do
        define_method(:initialize) do
          super()

          array :numbers, mapper: number_m.new
        end
      end
    end

    context "from a hash" do
      it "should prepend the errors with the indices" do
        result = syncer.new.pull(container.new, numbers: [2, 7, 3, 9])

        errors = [JM::Error.new([:numbers, 1], :unwanted_number),
                  JM::Error.new([:numbers, 3], :unwanted_number)]
        expect(result).to fail_with(errors)
      end
    end
  end

  context "when synchronizing an array property with inline validators" do
    let(:container) do
      Struct.new(:numbers)
    end

    let(:syncer) do
      Class.new(JM::DSL::Syncer) do
        define_method(:initialize) do
          super()

          array :numbers do
            element_validator do
              inline do |number|
                if number < 5
                  JM::Failure.new(JM::Error.new([], :too_small))
                else
                  JM::Success.new(number)
                end
              end
            end
          end
        end
      end
    end

    context "from a hash" do
      it "should prepend the errors with the indices" do
        result = syncer.new.pull(container.new, numbers: [2, 7, 3, 9])

        expect(result).to fail_with([JM::Error.new([:numbers, 0], :too_small),
                                     JM::Error.new([:numbers, 2], :too_small)])
      end
    end
  end

  context "when synchronizing an array property with an inline validator" do
    let(:container) do
      Struct.new(:numbers)
    end

    let(:syncer) do
      Class.new(JM::DSL::Syncer) do
        define_method(:initialize) do
          super()

          array :numbers, mapper: JM::Mappers::IdentityMapper.new do
            validator do
              inline do |numbers|
                if numbers.length < 3
                  JM::Failure.new(JM::Error.new([], :too_few))
                else
                  JM::Success.new(numbers)
                end
              end
            end
          end
        end
      end
    end

    context "from a hash" do
      it "should fail if the validation fails" do
        result = syncer.new.pull(container.new, numbers: [1, 5])

        expect(result).to fail_with(JM::Error.new([:numbers], :too_few))
      end
    end
  end

  context "when synchronizing an array property with an array validator" do
    let(:container) do
      Struct.new(:numbers)
    end

    let(:validator) do
      Class.new(JM::Validator) do
        def validate(array)
          if array.length > 1
            JM::Failure.new(JM::Error.new([], :too_many))
          else
            JM::Success.new(numbers)
          end
        end
      end
    end

    let(:syncer) do
      validator_class = validator

      Class.new(JM::DSL::Syncer) do
        define_method(:initialize) do
          super()

          array :numbers,
                mapper: JM::Mappers::IdentityMapper.new,
                validator: validator_class.new
        end
      end
    end

    context "from a hash" do
      it "should fail if the validation fails" do
        result = syncer.new.pull(container.new, numbers: [1, 5])

        expect(result).to fail_with(JM::Error.new([:numbers], :too_many))
      end
    end
  end
end
