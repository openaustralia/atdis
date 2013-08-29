require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Model do
  describe ".iso8601" do 
    it {ATDIS::Model.iso8601("2013-04-20T02:01:07Z").should == DateTime.new(2013,4,20,2,1,7)}
    it {ATDIS::Model.iso8601("2013-04-20").should == DateTime.new(2013,4,20)}
    it {ATDIS::Model.iso8601("2013-04-20T02:01:07+05:00").should == DateTime.new(2013,4,20,2,1,7,"+5")}
    it {ATDIS::Model.iso8601("2013-04-20T02:01:07-05:00").should == DateTime.new(2013,4,20,2,1,7,"-5")}
    it {ATDIS::Model.iso8601("2013-04").should == "2013-04"}
    it {ATDIS::Model.iso8601("18 September 2013").should == "18 September 2013"}
  end
end
