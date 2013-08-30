require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Application do

  describe ".interpret" do
    it "should parse the json and create an application object" do
      location, event1, event2, document1, document2, tuttle, buttle, application = double, double, double, double, double, double, double, double

      ATDIS::Location.should_receive(:interpret).with(:address => "123 Fourfivesix Street").and_return(location)
      ATDIS::Event.should_receive(:interpret).with(:id => "event1").and_return(event1)
      ATDIS::Event.should_receive(:interpret).with(:id => "event2").and_return(event2)
      ATDIS::Document.should_receive(:interpret).with(:ref => "27B/6/a").and_return(document1)
      ATDIS::Document.should_receive(:interpret).with(:ref => "27B/6/b").and_return(document2)
      ATDIS::Person.should_receive(:interpret).with(:name => "Tuttle").and_return(tuttle)
      ATDIS::Person.should_receive(:interpret).with(:name => "Buttle").and_return(buttle)
      ATDIS::Application.should_receive(:new).with(
        :dat_id => "DA2013-0381",
        :last_modified_date => "2013-04-20T02:01:07Z",
        :description => "New pool plus deck",
        :authority => "Example Council Shire Council",
        :lodgement_date => "2013-04-20T02:01:07Z",
        :determination_date => "2013-06-20",
        :notification_start_date => "2013-04-20T02:01:07Z",
        :notification_end_date => "2013-05-20T02:01:07Z",
        :officer => "Ms Smith",
        :estimated_cost => "50,000",
        :status => "OPEN",
        :more_info_url => "http://foo.com/bar",
        :comments_url => "http://foo.com/comment",
        :location => location,
        :events => [event1, event2],
        :documents => [document1, document2],
        :people => [tuttle, buttle]
      ).and_return(application)

      ATDIS::Application.interpret(
        :info => {
          :dat_id => "DA2013-0381",
          :last_modified_date => "2013-04-20T02:01:07Z",
          :description => "New pool plus deck",
          :authority => "Example Council Shire Council",
          :lodgement_date => "2013-04-20T02:01:07Z",
          :determination_date => "2013-06-20",
          :notification_start_date => "2013-04-20T02:01:07Z",
          :notification_end_date => "2013-05-20T02:01:07Z",
          :officer => "Ms Smith",
          # TODO: In ATDIS-1.0.3 it does not specify whether this is a float or a string
          # and whether to include (or not) AUD or dollar sign. For the time being we'll
          # just assume it's a free-form string
          :estimated_cost => "50,000",
          :status => "OPEN"
        },
        :reference => {
          :more_info_url => "http://foo.com/bar",
          :comments_url => "http://foo.com/comment"
        },
        :location => { :address => "123 Fourfivesix Street" },
        :events => [ { :id => "event1" }, { :id => "event2" } ],
        :documents => [ { :ref => "27B/6/a" }, { :ref => "27B/6/b" } ],
        :people => [ { :name => "Tuttle" }, { :name => "Buttle" } ]
      ).should == application
    end

    it "should create a nil valued application when there is no information in the json" do
      application = double
      ATDIS::Application.should_receive(:new).with({}).and_return(application)

      ATDIS::Application.interpret(:info => {}, :reference => {}).should == application
    end
  end

  describe "#last_modified_date=" do
    let(:a) { ATDIS::Application.new }
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

  describe "#lodgement_date=" do
    let(:a) { ATDIS::Application.new }
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

  describe "#more_info_url=" do
    let(:a) { ATDIS::Application.new }
    it "should do no type casting when it's already a URI" do
      a.more_info_url = URI.parse("http://foo.com/bar")
      a.more_info_url.should == URI.parse("http://foo.com/bar")
    end

    it "should cast a string to a URI when it's a valid url" do
      a.more_info_url = "http://foo.com/bar"
      a.more_info_url.should == URI.parse("http://foo.com/bar")
    end

    context "not a valid url" do
      before :each do
        a.more_info_url = "This is not a url"
      end
      it "should be nil" do      
        a.more_info_url.should be_nil
      end
      it "should keep the original string" do
        a.more_info_url_before_type_cast.should == "This is not a url"
      end
    end
  end

  describe "#description=" do
    let(:a) { ATDIS::Application.new }
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

  describe "validations" do
    let(:a) { ATDIS::Application.new(
      :dat_id => "DA2013-0381",
      :last_modified_date => DateTime.new(2013,4,20,2,1,7),
      :description => "New pool plus deck",
      :authority => "Example Council Shire Council",
      :lodgement_date => DateTime.new(2013,4,20,2,1,7),
      :determination_date => DateTime.new(2013,6,20),  
      :status => "OPEN",
      :more_info_url => URI.parse("http://foo.com/bar")
  ) }

    it { a.should be_valid }

    it ".dat_id" do
      a.dat_id = nil
      a.should_not be_valid
      a.errors.messages.should == {:dat_id => ["can't be blank"]}
    end

    describe ".last_modified_date" do
      it do
        a.last_modified_date = nil
        a.should_not be_valid
        a.errors.messages.should == {:last_modified_date => ["can't be blank"]}
      end
      it do
        a.last_modified_date = "18 January 2013"
        a.should_not be_valid
        a.errors.messages.should == {:last_modified_date => ["is not a valid date"]}
      end
    end

    describe ".description" do
      it do
        a.description = ""
        a.should_not be_valid
        a.errors.messages.should == {:description => ["can't be blank"]}
      end
    end

    describe ".authority" do
      it do
        a.authority = nil
        a.should_not be_valid
        a.errors.messages.should == {:authority => ["can't be blank"]}
      end
    end

    describe ".lodgement_date" do
      it do
        a.lodgement_date = nil
        a.should_not be_valid
        a.errors.messages.should == {:lodgement_date => ["can't be blank"]}
      end
      it do
        a.lodgement_date = "18 January 2013"
        a.should_not be_valid
        a.errors.messages.should == {:lodgement_date => ["is not a valid date"]}
      end
    end

    describe ".determination_date" do
      it do
        a.determination_date = nil
        a.should_not be_valid
        a.errors.messages.should == {:determination_date => ["can't be blank"]}
      end
      it do
        a.determination_date = "18 January 2013"
        a.should_not be_valid
        a.errors.messages.should == {:determination_date => ["is not a valid date"]}
      end
    end

    describe ".status" do
      it do
        a.status = nil
        a.should_not be_valid
        a.errors.messages.should == {:status => ["can't be blank"]}
      end
    end

    describe ".notification_start_date" do
      it do
        a.notification_start_date = DateTime.new(2013,4,20,2,1,7)
        a.should be_valid
      end
      it do
        a.notification_start_date = "18 January 2013"
        a.should_not be_valid
        a.errors.messages.should == {:notification_start_date => ["is not a valid date"]}
      end
    end

    describe ".notification_end_date" do
      it do
        a.notification_end_date = DateTime.new(2013,5,20,2,1,7)
        a.should be_valid
      end
      it do
        a.notification_end_date = "18 January 2013"
        a.should_not be_valid
        a.errors.messages.should == {:notification_end_date => ["is not a valid date"]}
      end
    end

    describe ".more_info_url" do
      it do
        a.more_info_url = nil
        a.should_not be_valid
        a.errors.messages.should == {:more_info_url => ["can't be blank"]}
      end
      it do
        a.more_info_url = "This is not a valid url"
        a.should_not be_valid
        a.errors.messages.should == {:more_info_url => ["is not a valid URL"]}
      end
    end
  end
end
