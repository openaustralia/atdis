require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class ModelB < ATDIS::Model
  set_field_mappings [
    [:bar, [:c, String]]
  ]
end

class ModelA < ATDIS::Model
  set_field_mappings [
    [:foo, [
      [:bar, [:a, String]],
      [:hello, [:b, ModelB]]
      ]]
  ]
end

describe ATDIS::Model do
  describe "#json_errors" do
    it "should return the json attribute with the errors" do
      a = ModelA.interpret(:foo => {:bar => "Hello"})
      a.errors.add(:a, ATDIS::ErrorMessage["can not be so friendly", "4.5"])
      a.errors.add(:a, ATDIS::ErrorMessage["and something else", "4.6"])
      a.json_errors.should == [[{:foo => {:bar => "Hello"}}, [
        ATDIS::ErrorMessage["bar can not be so friendly", "4.5"],
        ATDIS::ErrorMessage["bar and something else", "4.6"]]]]
    end

    it "should include the errors from child objects" do
      a = ModelA.interpret(:foo => {:hello => {:bar => "Kat"}})
      a.b.errors.add(:c, ATDIS::ErrorMessage["can't be a name", "2.3"])
      a.b.json_errors.should == [[{:bar => "Kat"}, [ATDIS::ErrorMessage["bar can't be a name", "2.3"]]]]
      a.json_errors.should == [[{:foo => {:hello => {:bar => "Kat"}}}, [ATDIS::ErrorMessage["bar can't be a name", "2.3"]]]]
    end

    it "should include the errors from only the first child object in an array" do
      a = ModelA.interpret(:foo => {:hello => [{:bar => "Kat"}, {:bar => "Mat"}]})
      a.b[0].c.should == "Kat"
      a.b[1].c.should == "Mat"
      a.json_errors.should == []
      a.b[0].errors.add(:c, ATDIS::ErrorMessage["can't be a name", "1.2"])
      a.b[1].errors.add(:c, ATDIS::ErrorMessage["can't be a name", "1.2"])
      a.json_errors.should == [[{:foo => {:hello => [{:bar => "Kat"}]}}, [ATDIS::ErrorMessage["bar can't be a name", "1.2"]]]]   
    end
  end

  describe ".json_top_level_attribute" do
    it { ModelA.json_top_level_attribute(:a).should == :bar }
    it { ModelA.json_top_level_attribute(:b).should == :hello }
    it { ModelB.json_top_level_attribute(:c).should == :bar }
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

  describe ".map_field" do
    let(:mappings) { { :foo => :bar, :a => :b, :info => { :foo => :bar2, :a => :b2, :c => :c2 } } }

    context "one version of data" do
      let(:data) { { :foo => 2, :a => 3, :d => 4, :info => { :foo => 2, :a => 3, :d => 4 } } }

      it { ATDIS::Model.map_field(:bar, data, mappings).should == 2 }
      it { ATDIS::Model.map_field(:b, data, mappings).should == 3 }
      it { ATDIS::Model.map_field(:bar2, data, mappings).should == 2 }
      it { ATDIS::Model.map_field(:b2, data, mappings).should == 3 }
      it { ATDIS::Model.map_field(:c2, data, mappings).should be_nil }
    end

    context "another version of data" do
      let(:data) { { :foo => 2, :a => 3, :d => 4 } }

      it { ATDIS::Model.map_field(:bar, data, mappings).should == 2 }
      it { ATDIS::Model.map_field(:b, data, mappings).should == 3 }
      it { ATDIS::Model.map_field(:bar2, data, mappings).should be_nil }
      it { ATDIS::Model.map_field(:b2, data, mappings).should be_nil }
      it { ATDIS::Model.map_field(:c2, data, mappings).should be_nil }
    end
  end

  describe ".unused_data" do
    it do
      ATDIS::Model.unused_data(
      {
        :foo => 2,
        :a => 3,
        :d => 4
      },
      {
        :foo => :bar,
        :a => :b
      }).should ==
      {
        :d => 4
      }
    end

    it do
      ATDIS::Model.unused_data(
      {
        :foo => 2,
        :a => 3,
        :d => 4,
        :info => {
          :foo => 2,
          :a => 3,
          :d => 4
        }
      },
      {
        :foo => :bar,
        :a => :b,
        :info => {
          :foo => :bar2,
          :a => :b2
        }
      }).should ==
      {
        :d => 4,
        :info => {
          :d => 4
        }
      }
    end
  end

  describe ".attribute_names_from_mappings" do
    it do
      # Doing this nastiness to support Ruby 1.8
      h = ActiveSupport::OrderedHash.new
      h[:foo] = :bar
      h[:a] = :b
      h2 = ActiveSupport::OrderedHash.new
      h2[:foo] = :bar2
      h2[:a] = :b2
      h[:info] = h2
      ATDIS::Model.attribute_names_from_mappings(h).should == [:bar, :b, :bar2, :b2]
    end
  end

  describe ".map_fields" do
    it do
      ATDIS::Model.map_fields(
      {
        :foo => 2,
        :a => 3,
        :d => 4
      },
      {
        :foo => :bar,
        :a => :b
      }).should ==
      {
        :bar => 2,
        :b => 3,
      }
    end

    it do
      ATDIS::Model.map_fields(
      {
        :foo => 2,
        :a => 3,
        :d => 4,
        :info => {
          :foo => 2,
          :a => 3,
          :d => 4
        }
      },
      {
        :foo => :bar,
        :a => :b,
        :info => {
          :foo => :bar2,
          :a => :b2
        }
      }).should ==
      {
        :bar => 2,
        :b => 3,
        :bar2 => 2,
        :b2 => 3
      }
    end
  end

  describe "#json_attribute" do
    let(:model) { ATDIS::Model.new }
    let(:mapping) { {:previous => :previous_page_no, :next => :next_page_no, :foo => {:bar => :apple, :foo => :orange}} }

    it "simple case" do
      model.json_attribute(:previous_page_no, 12, mapping).should == {:previous => 12}
    end

    it "with recursion" do
      model.json_attribute(:apple, 12, mapping).should == {:foo => {:bar => 12}}
    end
  end
end
