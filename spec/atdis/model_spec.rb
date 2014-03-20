require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class ModelB < ATDIS::Model
  set_field_mappings ({
    bar: [String]
  })
end

class ModelA < ATDIS::Model
  set_field_mappings ({
    bar:   [String],
    hello: [ModelB]
  })
end

describe ATDIS::Model do
  describe ".attributes" do
    it do
      a = ModelA.new(bar: "foo")
      a.attributes.should == {"bar" => "foo"}
    end
  end

  describe "#json_errors" do
    it "should return the json attribute with the errors" do
      a = ModelA.interpret(bar: "Hello")
      a.errors.add(:bar, ATDIS::ErrorMessage["can not be so friendly", "4.5"])
      a.errors.add(:bar, ATDIS::ErrorMessage["and something else", "4.6"])
      a.json_errors.should == [[{bar: "Hello"}, [
        ATDIS::ErrorMessage["bar can not be so friendly", "4.5"],
        ATDIS::ErrorMessage["bar and something else", "4.6"]]]]
    end

    it "should include the errors from child objects" do
      a = ModelA.interpret(hello: {bar: "Kat"})
      a.hello.errors.add(:bar, ATDIS::ErrorMessage["can't be a name", "2.3"])
      a.hello.json_errors.should == [[{bar: "Kat"}, [ATDIS::ErrorMessage["bar can't be a name", "2.3"]]]]
      a.json_errors.should == [[{hello: {bar: "Kat"}}, [ATDIS::ErrorMessage["bar can't be a name", "2.3"]]]]
    end

    it "should include the errors from only the first child object in an array" do
      a = ModelA.interpret(hello: [{bar: "Kat"}, {bar: "Mat"}])
      a.hello[0].bar.should == "Kat"
      a.hello[1].bar.should == "Mat"
      a.json_errors.should == []
      a.hello[0].errors.add(:bar, ATDIS::ErrorMessage["can't be a name", "1.2"])
      a.hello[1].errors.add(:bar, ATDIS::ErrorMessage["can't be a name", "1.2"])
      a.json_errors.should == [[{hello: [{bar: "Kat"}]}, [ATDIS::ErrorMessage["bar can't be a name", "1.2"]]]]
    end

    it "should show json parsing errors" do
      a = ModelA.interpret(invalid: {parameter: "foo"})
      a.should_not be_valid
      a.json_errors.should == [[nil, [ATDIS::ErrorMessage['Unexpected parameters in json data: {"invalid":{"parameter":"foo"}}', "4"]]]]
    end
  end

  describe ".cast" do
    it {ATDIS::Model.cast("2013-04-20T02:01:07Z", DateTime).should == DateTime.new(2013,4,20,2,1,7)}
    it {ATDIS::Model.cast("2013-04-20", DateTime).should == DateTime.new(2013,4,20)}
    it {ATDIS::Model.cast("2013-04-20T02:01:07+05:00", DateTime).should == DateTime.new(2013,4,20,2,1,7,"+5")}
    it {ATDIS::Model.cast("2013-04-20T02:01:07-05:00", DateTime).should == DateTime.new(2013,4,20,2,1,7,"-5")}
    it {ATDIS::Model.cast("2013-04", DateTime).should be_nil}
    it {ATDIS::Model.cast("18 September 2013", DateTime).should be_nil}
    it {ATDIS::Model.cast(DateTime.new(2013,4,20,2,1,7), DateTime).should == DateTime.new(2013,4,20,2,1,7)}

    it "should cast arrays by casting each member" do
      ATDIS::Model.cast([1, 2, 3], String).should == ["1", "2", "3"]
    end

    # This casting allows nil values
    describe "casting Fixnum" do
      it { ATDIS::Model.cast("3", Fixnum).should == 3}
      it { ATDIS::Model.cast("4.0", Fixnum).should == 4}
      it { ATDIS::Model.cast(5, Fixnum).should == 5}
      it { ATDIS::Model.cast(0, Fixnum).should == 0}
      it { ATDIS::Model.cast(nil, Fixnum).should be_nil}
    end
  end

  describe ".attribute_keys" do
    it do
      ATDIS::Model.attribute_types = {foo: String, a: Fixnum, info: String}
      ATDIS::Model.attribute_keys.should == [:foo, :a, :info]
    end
  end

  describe ".partition_by_used" do
    it do
      ATDIS::Model.stub(:attribute_keys).and_return([:foo])
      ATDIS::Model.partition_by_used({foo: 2}).should == [
        {foo: 2}, {}
      ]
    end

    it do
      ATDIS::Model.stub(:attribute_keys).and_return([:foo, :a])
      ATDIS::Model.partition_by_used({foo: 2, a: 3, d: 4}).should == [
        {foo: 2, a: 3},
        {d: 4}
      ]
    end

    it "something that isn't a hash will never get used" do
      ATDIS::Model.stub(:attribute_keys).and_return([:foo, :a])
      ATDIS::Model.partition_by_used("hello").should == [
        {},
        "hello"
      ]

    end
  end
end
