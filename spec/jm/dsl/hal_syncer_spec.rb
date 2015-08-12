describe JM::DSL::HALSyncer do
  let(:pet_class) do
    Struct.new(:name)
  end

  let(:pet_syncer) do
    pet_cls = pet_class

    Class.new(JM::DSL::HALSyncer) do
      define_method(:initialize) do
        super()

        self.source_factory = JM::Factories::NewFactory.new(pet_cls)

        self_link "/pets/{name}" do
          write do |pet|
            { "name" => pet.name }
          end

          read do |params|
            pet_cls.new(params["name"])
          end
        end

        property :name
      end
    end
  end

  let(:person_class) do
    Struct.new(:first_name, :last_name, :age)
  end

  context "when mapping a resource with 'self' link" do
    let(:syncer_class) do
      person = person_class

      Class.new(JM::DSL::HALSyncer) do
        define_method(:initialize) do
          super()

          self_link "/people/{name}" do
            read do |params|
              first_name, last_name = params["name"].split("-")

              person.new(first_name.capitalize, last_name.capitalize)
            end

            write do |p|
              name = "#{p.first_name.downcase}-#{p.last_name.downcase}"

              { "name" => name }
            end
          end

          property :age
        end
      end
    end

    context "to a hash" do
      it "should generate a self link" do
        person = person_class.new("Marten", "Lienen", 21)

        hash = syncer_class.new.push(person, {})

        resource = {
          "_links" => {
            "self" => { "href" => "/people/marten-lienen" }
          },
          "age" => 21
        }

        expect(hash).to succeed_with(resource)
      end
    end

    context "from a hash" do
      it "should not read the self link URI" do
        hash = {
          "_links" => {
            "self" => { "href" => "/people/marten-lienen" }
          },
          "age" => 21
        }

        result = syncer_class.new.pull(person_class.new, hash)

        expect(result).to succeed_with(person_class.new(nil, nil, 21))
      end
    end
  end

  context "when mapping a resource without a 'self' link" do
    let(:syncer_class) do
      Class.new(JM::DSL::HALSyncer) do
        define_method(:initialize) do
          super()

          property :age
        end
      end
    end

    context "to a hash" do
      it "should make no difference" do
        person = person_class.new("Marten", "Lienen", 21)

        result = syncer_class.new.push(person, {})

        expect(result).to succeed_with("age" => 21)
      end
    end
  end

  context "when linking to another 'self' linked entity" do
    let(:person_class) do
      Struct.new(:name, :pet)
    end

    let(:person_syncer) do
      pet_m = pet_syncer

      Class.new(JM::DSL::HALSyncer) do
        define_method(:initialize) do
          super()

          link :pet, pet_m.new

          property :name
        end
      end
    end

    context "and mapping to a hash" do
      it "should use the syncer's 'self' link syncer" do
        person = person_class.new("Frodo", pet_class.new("Finchen"))

        hash = person_syncer.new.push(person, {})

        expect(hash).to succeed_with("_links" => {
                                       "pet" => { "href" => "/pets/Finchen" }
                                     },
                                     "name" => "Frodo")
      end
    end

    context "and mapping from a hash" do
      it "should instantiate the object from the link" do
        hash = { "_links" => { "pet" => { "href" => "/pets/Finchen" } },
                 "name" => "Frodo" }

        result = person_syncer.new.pull(person_class.new, hash)

        expected = person_class.new("Frodo",
                                    pet_class.new("Finchen"))

        expect(result).to succeed_with(expected)
      end
    end
  end

  context "when mapping a 'self' as well as another link" do
    let(:person_class) do
      Struct.new(:name, :pet)
    end

    let(:person_syncer) do
      pet_m = pet_syncer
      person_cls = person_class

      Class.new(JM::DSL::HALSyncer) do
        define_method(:initialize) do
          super()

          self_link "/people/{name}" do
            read do |params|
              person_cls.new(params["name"])
            end

            write do |person|
              { "name" => person["name"] }
            end
          end

          link :pet,
               pet_m.new,
               accessor: JM::Accessors::AccessorAccessor.new(:pet)
        end
      end
    end

    context "to a hash" do
      it "should create both links" do
        person = person_class.new("Marten", pet_class.new("Ronja"))

        hash = person_syncer.new.push(person, {})

        expect(hash).to succeed_with("_links" => {
                                       "self" => { "href" => "/people/Marten" },
                                       "pet" => { "href" => "/pets/Ronja" }
                                     })
      end
    end

    context "from a hash" do
      it "should parse both links" do
        hash = { "_links" => { "self" => { "href" => "/people/Marten" },
                               "pet" => { "href" => "/pets/Ronja" } } }

        person = person_syncer.new.pull(person_class.new, hash)

        expect(person).to succeed_with(person_class.new(nil,
                                                        pet_class.new("Ronja")))
      end
    end
  end

  context "when mapping an array of links" do
    let(:person_class) do
      Struct.new(:name, :pets)
    end

    let(:person_syncer) do
      pet_m = pet_syncer

      Class.new(JM::DSL::HALSyncer) do
        define_method(:initialize) do
          super()

          links :pet,
                pet_m.new,
                accessor: JM::Accessors::AccessorAccessor.new(:pets)
        end
      end
    end

    context "to a hash" do
      it "should generate a HAL link array" do
        person = person_class.new("Marten", [pet_class.new("Finchen"),
                                             pet_class.new("Ronja")])

        hash = person_syncer.new.push(person, {})

        expect(hash).to succeed_with("_links" => {
                                       "pet" => [{ "href" => "/pets/Finchen" },
                                                 { "href" => "/pets/Ronja" }] })
      end
    end

    context "from a hash" do
      it "should map all links to objects" do
        hash = { "_links" => { "pet" => [{ "href" => "/pets/Finchen" },
                                         { "href" => "/pets/Ronja" }] } }

        person = person_syncer.new.pull(person_class.new, hash)

        expected = person_class.new(nil, [pet_class.new("Finchen"),
                                          pet_class.new("Ronja")])
        expect(person).to succeed_with(expected)
      end
    end
  end

  context "when mapping an embedded resource" do
    let(:person_class) do
      Struct.new(:name, :pet)
    end

    let(:person_syncer) do
      pet_m = pet_syncer

      Class.new(JM::DSL::HALSyncer) do
        define_method(:initialize) do
          super()

          embedded :pet, mapper: pet_m.new.to_mapper, push_only: false

          property :name
        end
      end
    end

    context "to a hash" do
      it "should embed the pet" do
        person = person_class.new("Marten", pet_class.new("Finchen"))

        hash = person_syncer.new.push(person, {}, "pet" => true)

        resource = {
          "_embedded" => {
            "pet" => {
              "_links" => {
                "self" => { "href" => "/pets/Finchen" }
              },
              "name" => "Finchen"
            }
          },
          "name" => "Marten"
        }

        expect(hash).to succeed_with(resource)
      end
    end

    context "from a hash" do
      it "should pull the embedded pet" do
        hash = {
          "_embedded" => {
            "pet" => {
              "_links" => { "self" => { "href" => "/pets/Finchen" } },
              "name" => "Finchen"
            }
          },
          "name" => "Marten"
        }

        person = person_syncer.new.pull(person_class.new, hash,
                                        "pet" => true)

        expected = person_class.new("Marten", pet_class.new("Finchen"))
        expect(person).to succeed_with(expected)
      end
    end
  end

  context "when mapping an embedded resource inline" do
    let(:person_class) do
      Struct.new(:name, :pet)
    end

    let(:person_syncer) do
      pet_cls = pet_class

      Class.new(JM::DSL::HALSyncer) do
        define_method(:initialize) do
          super()

          embedded :pet, push_only: false do
            mapper do
              self.source_factory = JM::Factories::NewFactory.new(pet_cls)

              property :name
            end
          end

          property :name
        end
      end
    end

    context "to a hash" do
      it "should use the inline syncer" do
        person = person_class.new("Marten", pet_class.new("Finchen"))

        hash = person_syncer.new.push(person, {}, "pet" => "true")

        resource = {
          "name" => "Marten",
          "_embedded" => {
            "pet" => {
              "name" => "Finchen"
            }
          }
        }
        expect(hash).to succeed_with(resource)
      end
    end

    context "from a hash" do
      it "should use the inline syncer" do
        hash = {
          "name" => "Marten",
          "_embedded" => {
            "pet" => {
              "name" => "Finchen"
            }
          }
        }

        person = person_syncer.new.pull(person_class.new, hash,
                                        "pet" => true)

        expected = person_class.new("Marten", pet_class.new("Finchen"))
        expect(person).to succeed_with(expected)
      end
    end
  end

  context "when mapping multiple embedded resources" do
    let(:person_class) do
      Struct.new(:name, :pets)
    end

    let(:person_syncer) do
      pet_m = pet_syncer

      Class.new(JM::DSL::HALSyncer) do
        define_method(:initialize) do
          super()

          embeddeds :pets, mapper: pet_m.new.to_mapper, push_only: false

          property :name
        end
      end
    end

    context "to a hash" do
      it "should embed the pets" do
        person = person_class.new("Marten", [pet_class.new("Finchen"),
                                             pet_class.new("Ronja")])

        hash = person_syncer.new.push(person, {}, "pets" => true)

        resource = {
          "_embedded" => {
            "pets" => [
              {
                "_links" => {
                  "self" => { "href" => "/pets/Finchen" }
                },
                "name" => "Finchen"
              },
              {
                "_links" => {
                  "self" => { "href" => "/pets/Ronja" }
                },
                "name" => "Ronja"
              }
            ]
          },
          "name" => "Marten"
        }

        expect(hash).to succeed_with(resource)
      end
    end

    context "from a hash" do
      it "should pull the embedded pet" do
        hash = {
          "_embedded" => {
            "pets" => [
              {
                "_links" => { "self" => { "href" => "/pets/Finchen" } },
                "name" => "Finchen"
              },
              {
                "_links" => { "self" => { "href" => "/pets/Ronja" } },
                "name" => "Ronja"
              }
            ]
          },
          "name" => "Marten"
        }

        person = person_syncer.new.pull(person_class.new, hash, "pets" => true)

        expected = person_class.new("Marten", [pet_class.new("Finchen"),
                                               pet_class.new("Ronja")])
        expect(person).to succeed_with(expected)
      end
    end
  end

  context "when mapping multiple embedded resources inline" do
    let(:person_class) do
      Struct.new(:name, :pets)
    end

    let(:person_syncer) do
      pet_cls = pet_class

      Class.new(JM::DSL::HALSyncer) do
        define_method(:initialize) do
          super()

          embeddeds :pets, push_only: false do
            mapper do
              self.source_factory = JM::Factories::NewFactory.new(pet_cls)

              property :name
            end
          end

          property :name
        end
      end
    end

    context "to a hash" do
      it "should use the inline syncer" do
        person = person_class.new("Marten", [pet_class.new("Finchen"),
                                             pet_class.new("Ronja")])

        hash = person_syncer.new.push(person, {}, "pets" => true)

        resource = {
          "_embedded" => {
            "pets" => [
              {
                "name" => "Finchen"
              },
              {
                "name" => "Ronja"
              }
            ]
          },
          "name" => "Marten"
        }

        expect(hash).to succeed_with(resource)
      end
    end

    context "from a hash" do
      it "should use the inline syncer" do
        hash = {
          "_embedded" => {
            "pets" => [
              {
                "name" => "Finchen"
              },
              {
                "name" => "Ronja"
              }
            ]
          },
          "name" => "Marten"
        }

        person = person_syncer.new.pull(person_class.new, hash, "pets" => true)

        expected = person_class.new("Marten", [pet_class.new("Finchen"),
                                               pet_class.new("Ronja")])
        expect(person).to succeed_with(expected)
      end
    end
  end

  context "when embedding objects" do
    let(:person_class) do
      Struct.new(:name, :favorite, :pets)
    end

    let(:person_syncer) do
      pet_m = pet_syncer

      Class.new(JM::DSL::HALSyncer) do
        define_method(:initialize) do
          super()

          embedded :favorite, mapper: pet_m.new.to_mapper
          embeddeds :pets, mapper: pet_m.new.to_mapper
        end
      end
    end

    it "should make them push-only by default" do
      hash = {
        "_embedded" => {
          "favorite" => {
            "_links" => {
              "self" => { "href" => "/pets/Finchen" }
            },
            "name" => "Finchen"
          },
          "pets" => [
            {
              "_links" => { "self" => { "href" => "/pets/Finchen" } },
              "name" => "Finchen"
            },
            {
              "_links" => { "self" => { "href" => "/pets/Ronja" } },
              "name" => "Ronja"
            }
          ]
        },
        "name" => "Marten"
      }

      person = person_syncer.new.pull(person_class.new, hash)

      expect(person).to succeed_with(person_class.new(nil, nil, nil))
    end
  end

  context "when using embedding options" do
    let(:person_class) { Struct.new(:name, :pets) }
    let(:person_syncer) do
      person_c = person_class
      p_syncer = pet_syncer

      Class.new(JM::DSL::HALSyncer) do
        define_method(:initialize) do
          super()

          self.source_factory = JM::Factories::NewFactory.new(person_c)

          property :name
          embeddeds :pets, mapper: p_syncer.new.to_mapper
        end
      end
    end

    let(:community) { Struct.new(:people) }
    let(:community_syncer) do
      p_syncer = person_syncer

      Class.new(JM::DSL::HALSyncer) do
        define_method(:initialize) do
          super()

          embeddeds :people, mapper: p_syncer.new.to_mapper
        end
      end
    end

    it "pushes only the requested embeddings" do
      c = community.new([person_class.new("Marten", [pet_class.new("Fini")]),
                         person_class.new("Maja", [pet_class.new("Ronja")])])

      syncer = community_syncer.new
      result = syncer.push(c, {}, "people" => true)
      resource = {
        "_embedded" => {
          "people" => [
            { "name" => "Marten" },
            { "name" => "Maja" }
          ]
        }
      }

      expect(result).to succeed_with(resource)
    end
  end

  context "when a link is missing" do
    let(:person_class) do
      Struct.new(:name, :pet)
    end

    let(:pet_syncer) do
      pet_c = pet_class

      Class.new(JM::DSL::HALSyncer) do
        define_method(:initialize) do
          super()

          self_link "/pets/{name}" do
            read do |params|
              pet_c.new(params["name"])
            end
          end
        end
      end
    end

    let(:person_syncer) do
      pet_p = pet_syncer.new

      Class.new(JM::DSL::HALSyncer) do
        define_method(:initialize) do
          super()

          link :pet, pet_p
        end
      end
    end

    it "should not push anything" do
      result = person_syncer.new.pull(person_class.new, {})

      expect(result).to succeed_with(person_class.new)
    end
  end
end
