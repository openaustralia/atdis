require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Info do
  let(:a) { ATDIS::Info.new(
    dat_id: "DA2013-0381",
    development_type: "residential",
    last_modified_date: DateTime.new(2013,4,20,2,1,7),
    description: "New pool plus deck",
    authority: "Example Council Shire Council",
    lodgement_date: DateTime.new(2013,4,20,2,1,7),
    determination_date: DateTime.new(2013,6,20),
    determination_type: "Pending",
    status: "OPEN",
  )}

  describe "determination_type" do
    context "is missing" do
      before(:each) { a.determination_type = nil}
      it {
        a.should_not be_valid
        a.errors.messages.should == {determination_type: [ATDIS::ErrorMessage.new("can't be blank", "4.3.1")]}
      }
    end
  end

  describe "notification_date" do
    it "both valid start and end dates" do
      a.notification_start_date = DateTime.new(2013,4,20,2,1,7)
      a.notification_end_date = DateTime.new(2013,5,20,0,0,0)
      a.should be_valid
    end

    it "invalid start date" do
      a.notification_start_date = "18 January 2013"
      a.notification_end_date = DateTime.new(2013,2,1,0,0,0)
      a.should_not be_valid
      a.errors.messages.should == {notification_start_date: [ATDIS::ErrorMessage["is not a valid date or none", "4.3.1"]]}
    end

    it "invalid end date" do
      a.notification_start_date = DateTime.new(2013,1,10,0,0,0)
      a.notification_end_date = "18 January 2013"
      a.should_not be_valid
      a.errors.messages.should == {notification_end_date: [ATDIS::ErrorMessage["is not a valid date or none", "4.3.1"]]}
    end

    it "only start date set" do
      a.notification_start_date = DateTime.new(2013,4,20,2,1,7)
      a.should_not be_valid
      a.errors.messages.should == {notification_end_date: [ATDIS::ErrorMessage["can not be blank if notification_start_date is set", "4.3.1"]]}
    end

    it "only end date set" do
      a.notification_end_date = DateTime.new(2013,4,20,2,1,7)
      a.should_not be_valid
      a.errors.messages.should == {notification_start_date: [ATDIS::ErrorMessage["can not be blank if notification_end_date is set", "4.3.1"]]}
    end

    it "end date is before start date" do
      a.notification_start_date = DateTime.new(2013,5,20,0,0,0)
      a.notification_end_date = DateTime.new(2013,4,20,2,1,7)
      a.should_not be_valid
      a.errors.messages.should == {notification_end_date: [ATDIS::ErrorMessage["can not be earlier than notification_start_date", "4.3.1"]]}
    end

    it "both dates set to none" do
      a.notification_start_date = "none"
      a.notification_end_date = "none"
      a.notification_start_date.should be_nil
      a.notification_end_date.should be_nil
      a.should be_valid
    end

    it "only start date set to none" do
      a.notification_start_date = "none"
      a.notification_end_date = DateTime.new(2013,2,1,0,0,0)
      a.should_not be_valid
      a.errors.messages.should == {notification_start_date: [ATDIS::ErrorMessage["can't be none unless notification_end_date is none as well", "4.3.1"]]}
    end

    it "only end date set to none" do
      a.notification_start_date = DateTime.new(2013,2,1,0,0,0)
      a.notification_end_date = "none"
      a.should_not be_valid
      a.errors.messages.should == {notification_end_date: [ATDIS::ErrorMessage["can't be none unless notification_start_date is none as well", "4.3.1"]]}
    end
  end

  describe ".status" do
    it do
      a.status = nil
      a.should_not be_valid
      a.errors.messages.should == {status: [ATDIS::ErrorMessage["can't be blank", "4.3.1"]]}
    end
  end

  describe ".determination_date" do
    it do
      a.determination_date = nil
      a.should_not be_valid
      a.errors.messages.should == {determination_date: [ATDIS::ErrorMessage["can't be blank", "4.3.1"]]}
    end
    it do
      a.determination_date = "18 January 2013"
      a.should_not be_valid
      a.errors.messages.should == {determination_date: [ATDIS::ErrorMessage["is not a valid date or none", "4.3.1"]]}
    end
    it "none should be allowed if the application is not yet determined" do
      a.determination_date = "none"
      a.determination_date.should be_nil
      a.should be_valid
    end
  end

  describe ".lodgement_date" do
    it do
      a.lodgement_date = nil
      a.should_not be_valid
      a.errors.messages.should == {lodgement_date: [ATDIS::ErrorMessage["can't be blank", "4.3.1"]]}
    end
    it do
      a.lodgement_date = "18 January 2013"
      a.should_not be_valid
      a.errors.messages.should == {lodgement_date: [ATDIS::ErrorMessage["is not a valid date", "4.3.8"]]}
    end
  end

  describe ".authority" do
    it do
      a.authority = nil
      a.should_not be_valid
      a.errors.messages.should == {authority: [ATDIS::ErrorMessage["can't be blank", "4.3.1"]]}
    end
  end

  describe ".description" do
    it do
      a.description = ""
      a.should_not be_valid
      a.errors.messages.should == {description: [ATDIS::ErrorMessage["can't be blank", "4.3.1"]]}
    end
  end

  describe ".last_modified_date" do
    it do
      a.last_modified_date = nil
      a.should_not be_valid
      a.errors.messages.should == {last_modified_date: [ATDIS::ErrorMessage["can't be blank", "4.3.1"]]}
    end
    it do
      a.last_modified_date = "18 January 2013"
      a.should_not be_valid
      a.errors.messages.should == {last_modified_date: [ATDIS::ErrorMessage["is not a valid date", "4.3.8"]]}
    end
  end

  it ".dat_id" do
    a.dat_id = nil
    a.should_not be_valid
    a.errors.messages.should == {dat_id: [ATDIS::ErrorMessage["can't be blank", "4.3.1"]]}
  end

  describe "#description=" do
    let(:a) { ATDIS::Info.new }
    it "should do not type casting when it's already a String" do
      a.description = "foo"
      a.description.should == "foo"
    end
    context "not a string" do
      before :each do
        a.description = 123
      end
      it "should cast to a string when it's not a string" do
        a.description.should == "123"
      end
      it "should keep the original value" do
        a.description_before_type_cast.should == 123
      end
    end
  end

  describe "#lodgement_date=" do
    let(:a) { ATDIS::Info.new }
    it "should do no type casting when it's already a date" do
      a.lodgement_date = DateTime.new(2013,1,1)
      a.lodgement_date.should == DateTime.new(2013,1,1)
    end

    it "should cast a string to a date when it's a valid date" do
      a.lodgement_date = "2013-01-01"
      a.lodgement_date.should == DateTime.new(2013,1,1)
    end

    context "not a valid date" do
      before :each do
        a.lodgement_date = "2013/01/01"
      end
      it "should be nil" do
        a.lodgement_date.should be_nil
      end
      it "should keep the original string" do
        a.lodgement_date_before_type_cast.should == "2013/01/01"
      end
    end
  end

  describe "#last_modified_date=" do
    let(:a) { ATDIS::Info.new }
    it "should do no type casting when it's already a date" do
      a.last_modified_date = DateTime.new(2013,1,1)
      a.last_modified_date.should == DateTime.new(2013,1,1)
    end

    it "should cast a string to a date when it's a valid date" do
      a.last_modified_date = "2013-01-01"
      a.last_modified_date.should == DateTime.new(2013,1,1)
    end

    context "not a valid date" do
      before :each do
        a.last_modified_date = "2013/01/01"
      end
      it "should be nil" do
        a.last_modified_date.should be_nil
      end
      it "should keep the original string" do
        a.last_modified_date_before_type_cast.should == "2013/01/01"
      end
    end
  end

end
