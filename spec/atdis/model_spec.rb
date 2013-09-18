require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Model do
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
    let(:mappings) { { :foo => :bar, :a => :b, :info => { :foo => :bar2, :a => :b2 } } }

    it { ATDIS::Model.map_field(:foo, mappings).should == :bar }
    it { ATDIS::Model.map_field(:a, mappings).should == :b }
    it { ATDIS::Model.map_field(:d, mappings).should be_nil }

    it { ATDIS::Model.map_field({:info => :foo}, mappings).should == :bar2 }
    it { ATDIS::Model.map_field({:info => :a}, mappings).should == :b2 }
    it { ATDIS::Model.map_field({:info => :d}, mappings).should be_nil }
  end

  describe ".map_field2" do
    let(:mappings) { { :foo => :bar, :a => :b, :info => { :foo => :bar2, :a => :b2, :c => :c2 } } }
    let(:data) { { :foo => 2, :a => 3, :d => 4, :info => { :foo => 2, :a => 3, :d => 4 } } }

    it { ATDIS::Model.map_field2(:bar, data, mappings).should == 2 }
    it { ATDIS::Model.map_field2(:b, data, mappings).should == 3 }
    it { ATDIS::Model.map_field2(:bar2, data, mappings).should == 2 }
    it { ATDIS::Model.map_field2(:b2, data, mappings).should == 3 }
    it { ATDIS::Model.map_field2(:c2, data, mappings).should be_nil }
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
        :json_left_overs => {
          :d => 4
        }
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
        :b2 => 3,
        :json_left_overs => {
          :d => 4,
          :info => {
            :d => 4
          }
        }
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
