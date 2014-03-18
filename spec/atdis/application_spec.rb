require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Application do

  context "extra parameter in json" do
    it "should not be valid" do
      ATDIS::Location.should_receive(:interpret).with(foo: "Some location data").and_return(double(valid?: true))
      a = ATDIS::Application.interpret(application: {
        info: {
          dat_id: "DA2013-0381",
          development_type: "residential",
          last_modified_date: "2013-04-20T02:01:07Z",
          description: "New pool plus deck",
          authority: "Example Council Shire Council",
          lodgement_date: "2013-04-20T02:01:07Z",
          determination_date: "2013-06-20",
          status: "OPEN"
        },
        reference: {
          # This is the extra parameter that shouldn't be here
          foo: "bar",
          more_info_url: "http://foo.com/bar"
        },
        location: {foo: "Some location data"},
        events: [],
        documents: []
      })
      a.should_not be_valid
      a.errors.messages.should == {json: [ATDIS::ErrorMessage['Unexpected parameters in json data: {"application":{"reference":{"foo":"bar"}}}', "4"]]}
    end
  end

  describe ".interpret" do
    it "should parse the json and create an application object" do
      application = double

      ATDIS::Application.should_receive(:new).with(
        dat_id: "DA2013-0381",
        development_type: "residential",
        last_modified_date: "2013-04-20T02:01:07Z",
        description: "New pool plus deck",
        authority: "Example Council Shire Council",
        lodgement_date: "2013-04-20T02:01:07Z",
        determination_date: "2013-06-20",
        notification_start_date: "2013-04-20T02:01:07Z",
        notification_end_date: "2013-05-20T02:01:07Z",
        officer: "Ms Smith",
        estimated_cost: "50,000",
        status: "OPEN",
        more_info_url: "http://foo.com/bar",
        comments_url: "http://foo.com/comment",
        location: { address: "123 Fourfivesix Street" },
        events: [ { id: "event1" }, { id: "event2" } ],
        documents: [ { ref: "27B/6/a" }, { ref: "27B/6/b" } ],
        people: [ { name: "Tuttle" }, { name: "Buttle" } ],
        extended: {another_parameter: "with some value", anything: "can go here"},
        json_left_overs: {}
      ).and_return(application)

      ATDIS::Application.interpret(application: {
        info: {
          dat_id: "DA2013-0381",
          development_type: "residential",
          last_modified_date: "2013-04-20T02:01:07Z",
          description: "New pool plus deck",
          authority: "Example Council Shire Council",
          lodgement_date: "2013-04-20T02:01:07Z",
          determination_date: "2013-06-20",
          notification_start_date: "2013-04-20T02:01:07Z",
          notification_end_date: "2013-05-20T02:01:07Z",
          officer: "Ms Smith",
          # TODO: In ATDIS-1.0.3 it does not specify whether this is a float or a string
          # and whether to include (or not) AUD or dollar sign. For the time being we'll
          # just assume it's a free-form string
          estimated_cost: "50,000",
          status: "OPEN"
        },
        reference: {
          more_info_url: "http://foo.com/bar",
          comments_url: "http://foo.com/comment"
        },
        location: { address: "123 Fourfivesix Street" },
        events: [ { id: "event1" }, { id: "event2" } ],
        documents: [ { ref: "27B/6/a" }, { ref: "27B/6/b" } ],
        people: [ { name: "Tuttle" }, { name: "Buttle" } ],
        extended: {another_parameter: "with some value", anything: "can go here"}
      }).should == application
    end

    it "should create a nil valued application when there is no information in the json" do
      application = double
      ATDIS::Application.should_receive(:new).with({json_left_overs:{}, status:nil, determination_date:nil, estimated_cost:nil,
        comments_url:nil, description:nil, more_info_url:nil, dat_id:nil, development_type:nil, notification_start_date:nil, location:nil,
        extended:nil, events:nil, last_modified_date:nil, notification_end_date:nil, documents:nil, authority:nil,
        lodgement_date:nil, officer:nil, people:nil}).and_return(application)

      ATDIS::Application.interpret(application: {info: {}, reference: {}}).should == application
    end
  end

  describe "#extended" do
    it "should do no typecasting" do
      a = ATDIS::Application.new(extended: {another_parameter: "with some value", anything: "can go here"})
      a.extended.should == {another_parameter: "with some value", anything: "can go here"}
    end
  end

  describe "#location=" do
    let(:a) { ATDIS::Application.new }
    it "should type cast to a location" do
      location = double
      ATDIS::Location.should_receive(:interpret).with(address: "123 Fourfivesix Street").and_return(location)
      a.location = { address: "123 Fourfivesix Street" }
      a.location.should == location
    end

    it "should not cast when it's already a location" do
      l = ATDIS::Location.new
      a.location = l
      a.location.should == l
    end
  end

  describe "#events" do
    let(:a) { ATDIS::Application.new }
    it "should type cast to several events" do
      event1, event2 = double, double
      ATDIS::Event.should_receive(:interpret).with(id: "event1").and_return(event1)
      ATDIS::Event.should_receive(:interpret).with(id: "event2").and_return(event2)
      a.events = [ { id: "event1" }, { id: "event2" } ]
      a.events.should == [event1, event2]
    end
  end

  describe "#documents" do
    let(:a) { ATDIS::Application.new }
    it "should type cast to several documents" do
      document1, document2 = double, double
      ATDIS::Document.should_receive(:interpret).with(ref: "27B/6/a").and_return(document1)
      ATDIS::Document.should_receive(:interpret).with(ref: "27B/6/b").and_return(document2)
      a.documents = [ { ref: "27B/6/a" }, { ref: "27B/6/b" } ]
      a.documents.should == [document1, document2]
    end
  end

  describe "#people" do
    let(:a) { ATDIS::Application.new }
    it "should type cast to several people" do
      tuttle, buttle = double, double
      ATDIS::Person.should_receive(:interpret).with(name: "Tuttle").and_return(tuttle)
      ATDIS::Person.should_receive(:interpret).with(name: "Buttle").and_return(buttle)
      a.people = [ { name: "Tuttle" }, { name: "Buttle" } ]
      a.people.should == [tuttle, buttle]
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

  # TODO This should really be a test on the Model base class
  describe ".attributes" do
    it do
      a = ATDIS::Application.new(dat_id: "DA2013-0381", description: "New pool plus deck")
      a.attributes.should == {"dat_id" => "DA2013-0381", "description" => "New pool plus deck"}
    end
  end

  # TODO This should really be a test on the Model base class
  describe "#attribute_names" do
    it do
      # These are also ordered in a way that corresponds to the specification. Makes for easy reading by humans.
      ATDIS::Application.attribute_names.should == [
        "dat_id",
        "development_type",
        "last_modified_date",
        "description",
        "authority",
        "lodgement_date",
        "determination_date",
        "status",
        "notification_start_date",
        "notification_end_date",
        "officer",
        "estimated_cost",
        "more_info_url",
        "comments_url",
        "location",
        "events",
        "documents",
        "people",
        "extended"
      ]
    end
  end

  describe "validations" do
    before :each do
      l = double(valid?: true)
      ATDIS::Location.should_receive(:interpret).with(address: "123 Fourfivesix Street Neutral Bay NSW 2089").and_return(l)
    end

    let(:a) { ATDIS::Application.new(
      dat_id: "DA2013-0381",
      development_type: "residential",
      last_modified_date: DateTime.new(2013,4,20,2,1,7),
      description: "New pool plus deck",
      authority: "Example Council Shire Council",
      lodgement_date: DateTime.new(2013,4,20,2,1,7),
      determination_date: DateTime.new(2013,6,20),
      status: "OPEN",
      more_info_url: URI.parse("http://foo.com/bar"),
      location: {address: "123 Fourfivesix Street Neutral Bay NSW 2089"},
      events: [],
      documents: []
  ) }

    it { a.should be_valid }

    describe ".location" do
      it "should not be valid if the location is not valid" do
        l = double(valid?: false)
        ATDIS::Location.should_receive(:interpret).with(foo: "some location data").and_return(l)
        a.location = {foo: "some location data"}
        a.should_not be_valid
      end
    end

    it ".dat_id" do
      a.dat_id = nil
      a.should_not be_valid
      a.errors.messages.should == {dat_id: [ATDIS::ErrorMessage["can't be blank", "4.3.1"]]}
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

    describe ".description" do
      it do
        a.description = ""
        a.should_not be_valid
        a.errors.messages.should == {description: [ATDIS::ErrorMessage["can't be blank", "4.3.1"]]}
      end
    end

    describe ".authority" do
      it do
        a.authority = nil
        a.should_not be_valid
        a.errors.messages.should == {authority: [ATDIS::ErrorMessage["can't be blank", "4.3.1"]]}
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

    describe ".status" do
      it do
        a.status = nil
        a.should_not be_valid
        a.errors.messages.should == {status: [ATDIS::ErrorMessage["can't be blank", "4.3.1"]]}
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

    describe ".more_info_url" do
      it do
        a.more_info_url = nil
        a.should_not be_valid
        a.errors.messages.should == {more_info_url: [ATDIS::ErrorMessage["can't be blank", "4.3.2"]]}
      end
      it do
        a.more_info_url = "This is not a valid url"
        a.should_not be_valid
        a.errors.messages.should == {more_info_url: [ATDIS::ErrorMessage["is not a valid URL", "4.3.2"]]}
      end
      it do
        a.more_info_url = "foo.com"
        a.should_not be_valid
        a.errors.messages.should == {more_info_url: [ATDIS::ErrorMessage["is not a valid URL", "4.3.2"]]}
      end
      it do
        a.more_info_url = "httpss://foo.com"
        a.should_not be_valid
        a.errors.messages.should == {more_info_url: [ATDIS::ErrorMessage["is not a valid URL", "4.3.2"]]}
      end
    end

    describe "events" do
      it "has to be an array" do
        ATDIS::Event.should_receive(:interpret).with(foo: "bar").and_return(double(valid?: true))
        a.events = {foo: "bar"}
        #a.events.should be_nil
        a.should_not be_valid
        a.errors.messages.should == {events: [ATDIS::ErrorMessage["should be an array", "4.3.4"]]}
      end

      it "can be an empty array" do
        a.events = []
        a.events.should == []
        a.should be_valid
      end

      it "can not be empty" do
        a.events = nil
        a.should_not be_valid
        a.errors.messages.should == {events: [ATDIS::ErrorMessage["can't be blank", "4.3.4"]]}
      end
    end
  end
end
