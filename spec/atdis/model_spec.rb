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
  end

  describe ".map_fields" do
    it do
      ATDIS::Model.map_fields({:foo => :bar, :a => :b}, {:foo => 2, :a => 3, :d => 4}).should ==
        {:bar => 2, :b => 3, :json_left_overs => {:d => 4}}
    end

    it do
      ATDIS::Model.map_fields({:foo => :bar, :a => :b, :info => {:foo => :bar2, :a => :b2}},
        {:foo => 2, :a => 3, :d => 4, :info => {:foo => 2, :a => 3, :d => 4}}).should ==
        {:bar => 2, :b => 3, :bar2 => 2, :b2 => 3, :json_left_overs => {:d => 4, :info => {:d => 4}}}
    end
  end
end
