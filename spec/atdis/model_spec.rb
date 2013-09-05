require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Model do
  describe ".cast_datetime" do 
    it {ATDIS::Model.cast_datetime("2013-04-20T02:01:07Z").should == DateTime.new(2013,4,20,2,1,7)}
    it {ATDIS::Model.cast_datetime("2013-04-20").should == DateTime.new(2013,4,20)}
    it {ATDIS::Model.cast_datetime("2013-04-20T02:01:07+05:00").should == DateTime.new(2013,4,20,2,1,7,"+5")}
    it {ATDIS::Model.cast_datetime("2013-04-20T02:01:07-05:00").should == DateTime.new(2013,4,20,2,1,7,"-5")}
    it {ATDIS::Model.cast_datetime("2013-04").should be_nil}
    it {ATDIS::Model.cast_datetime("18 September 2013").should be_nil}
    it {ATDIS::Model.cast_datetime(DateTime.new(2013,4,20,2,1,7)).should == DateTime.new(2013,4,20,2,1,7)}
  end

  describe ".map_fields" do
    it do
      ATDIS::Model.map_fields({:foo => :bar, :a => :b}, {:foo => 2, :a => 3, :d => 4}).should ==
        [{:bar => 2, :b => 3}, {:d => 4}]
    end

    it do
      ATDIS::Model.map_fields({:foo => :bar, :a => :b, :info => {:foo => :bar2, :a => :b2}},
        {:foo => 2, :a => 3, :d => 4, :info => {:foo => 2, :a => 3, :d => 4}}).should ==
        [{:bar => 2, :b => 3, :bar2 => 2, :b2 => 3}, {:d => 4, :info => {:d => 4}}]
    end
  end
end
