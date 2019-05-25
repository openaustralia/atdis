require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

class ModelB < ATDIS::Model
  field_mappings(
    bar: [String]
  )
end

class ModelA < ATDIS::Model
  field_mappings(
    bar:   [String],
    hello: [ModelB]
  )
end

describe ATDIS::Model do
  describe ".attributes" do
    it do
      a = ModelA.new(bar: "foo")
      expect(a.attributes).to eq("bar" => "foo")
    end
  end

  describe "#json_errors" do
    it "should return the json attribute with the errors" do
      a = ModelA.interpret(bar: "Hello")
      a.errors.add(:bar, ATDIS::ErrorMessage["can not be so friendly", "4.5"])
      a.errors.add(:bar, ATDIS::ErrorMessage["and something else", "4.6"])
      expect(a.json_errors).to eq(
        [[
          { bar: "Hello" },
          [
            ATDIS::ErrorMessage["bar can not be so friendly", "4.5"],
            ATDIS::ErrorMessage["bar and something else", "4.6"]
          ]
        ]]
      )
    end

    it "should include the errors from child objects" do
      a = ModelA.interpret(hello: { bar: "Kat" })
      a.hello.errors.add(:bar, ATDIS::ErrorMessage["can't be a name", "2.3"])
      expect(a.hello.json_errors).to eq [[{ bar: "Kat" }, [ATDIS::ErrorMessage["bar can't be a name", "2.3"]]]]
      expect(a.json_errors).to eq [[{ hello: { bar: "Kat" } }, [ATDIS::ErrorMessage["bar can't be a name", "2.3"]]]]
    end

    it "should include the errors from only the first child object in an array" do
      a = ModelA.interpret(hello: [{ bar: "Kat" }, { bar: "Mat" }])
      expect(a.hello[0].bar).to eq "Kat"
      expect(a.hello[1].bar).to eq "Mat"
      expect(a.json_errors).to eq []
      a.hello[0].errors.add(:bar, ATDIS::ErrorMessage["can't be a name", "1.2"])
      a.hello[1].errors.add(:bar, ATDIS::ErrorMessage["can't be a name", "1.2"])
      expect(a.json_errors).to eq [[{ hello: [{ bar: "Kat" }] }, [ATDIS::ErrorMessage["bar can't be a name", "1.2"]]]]
    end

    it "should show json parsing errors" do
      a = ModelA.interpret(invalid: { parameter: "foo" })
      expect(a).to_not be_valid
      expect(a.json_errors).to eq [[nil, [ATDIS::ErrorMessage['Unexpected parameters in json data: {"invalid":{"parameter":"foo"}}', "4"]]]]
    end

    it "should json errors even if value is nil" do
      b = ModelB.new
      b.errors.add(:bar, ATDIS::ErrorMessage.new("can't be nil", "1.2"))
      expect(b.json_errors).to eq [[{ bar: nil }, [ATDIS::ErrorMessage.new("bar can't be nil", "1.2")]]]
    end
  end

  describe ".cast" do
    it { expect(ATDIS::Model.cast("2013-04-20T02:01:07Z", DateTime)).to eq DateTime.new(2013, 4, 20, 2, 1, 7) }
    it { expect(ATDIS::Model.cast("2013-04-20", DateTime)).to eq DateTime.new(2013, 4, 20) }
    it { expect(ATDIS::Model.cast("2013-04-20T02:01:07+05:00", DateTime)).to eq DateTime.new(2013, 4, 20, 2, 1, 7, "+5") }
    it { expect(ATDIS::Model.cast("2013-04-20T02:01:07-05:00", DateTime)).to eq DateTime.new(2013, 4, 20, 2, 1, 7, "-5") }
    it { expect(ATDIS::Model.cast("2013-04", DateTime)).to be_nil }
    it { expect(ATDIS::Model.cast("18 September 2013", DateTime)).to be_nil }
    it { expect(ATDIS::Model.cast(DateTime.new(2013, 4, 20, 2, 1, 7), DateTime)).to eq DateTime.new(2013, 4, 20, 2, 1, 7) }

    it "should cast arrays by casting each member" do
      expect(ATDIS::Model.cast([1, 2, 3], String)).to eq %w[1 2 3]
    end

    # This casting allows nil values
    describe "casting Fixnum" do
      it { expect(ATDIS::Model.cast("3", Fixnum)).to eq 3 }
      it { expect(ATDIS::Model.cast("4.0", Fixnum)).to eq 4 }
      it { expect(ATDIS::Model.cast(5, Fixnum)).to eq 5 }
      it { expect(ATDIS::Model.cast(0, Fixnum)).to eq 0 }
      it { expect(ATDIS::Model.cast(nil, Fixnum)).to be_nil }
    end
  end

  describe ".attribute_keys" do
    it do
      ATDIS::Model.attribute_types = { foo: String, a: Fixnum, info: String }
      expect(ATDIS::Model.attribute_keys).to eq %i[foo a info]
    end
  end

  describe ".partition_by_used" do
    it do
      allow(ATDIS::Model).to receive(:attribute_keys).and_return([:foo])
      expect(ATDIS::Model.partition_by_used(foo: 2)).to eq [
        { foo: 2 }, {}
      ]
    end

    it do
      allow(ATDIS::Model).to receive(:attribute_keys).and_return(%i[foo a])
      expect(ATDIS::Model.partition_by_used(foo: 2, a: 3, d: 4)).to eq [
        { foo: 2, a: 3 },
        { d: 4 }
      ]
    end

    it "something that isn't a hash will never get used" do
      allow(ATDIS::Model).to receive(:attribute_keys).and_return(%i[foo a])
      expect(ATDIS::Model.partition_by_used("hello")).to eq [
        {},
        "hello"
      ]
    end
  end
end
