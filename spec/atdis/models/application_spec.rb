require "spec_helper"

describe ATDIS::Models::Application do
  context "extra parameter in json" do
    it "should not be valid" do
      ATDIS::Models::Location.should_receive(:interpret).with("location").and_return(double(valid?: true))
      ATDIS::Models::Document.should_receive(:interpret).with("document").and_return(double(valid?: true))
      ATDIS::Models::Event.should_receive(:interpret).with("event").and_return(double(valid?: true))

      a = ATDIS::Models::Application.interpret(
        info: {
          dat_id: "DA2013-0381",
          development_type: "residential",
          last_modified_date: "2013-04-20T02:01:07Z",
          description: "New pool plus deck",
          authority: {
            ref:  "http://www.council.nsw.gov.au/atdis/1.0",
            name: "Example Council Shire Council"
          },
          lodgement_date: "2013-04-20T02:01:07Z",
          determination_date: "2013-06-20",
          determination_type: "Pending",
          status: "OPEN"
        },
        reference: {
          more_info_url: "http://foo.com/bar"
        },
        # This is the extra parameter that shouldn't be here
        foo: "bar",
        locations: ["location"],
        events: ["event"],
        documents: ["document"]
      )
      a.should_not be_valid
      a.errors.messages.should == {json: [ATDIS::ErrorMessage['Unexpected parameters in json data: {"foo":"bar"}', "4"]]}
    end
  end

  describe ".interpret" do
    it "should parse the json and create an application object" do
      application = double

      ATDIS::Models::Application.should_receive(:new).with(
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
          estimated_cost: "50,000",
          status: "OPEN",
        },
        reference: {
          more_info_url: "http://foo.com/bar",
          comments_url: "http://foo.com/comment",
        },
        locations: [{ address: "123 Fourfivesix Street" }],
        events: [ { id: "event1" }, { id: "event2" } ],
        documents: [ { ref: "27B/6/a" }, { ref: "27B/6/b" } ],
        people: [ { name: "Tuttle" }, { name: "Buttle" } ],
        extended: {another_parameter: "with some value", anything: "can go here"},
        json_left_overs: {}
      ).and_return(application)

      ATDIS::Models::Application.interpret(
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
        locations: [{ address: "123 Fourfivesix Street" }],
        events: [ { id: "event1" }, { id: "event2" } ],
        documents: [ { ref: "27B/6/a" }, { ref: "27B/6/b" } ],
        people: [ { name: "Tuttle" }, { name: "Buttle" } ],
        extended: {another_parameter: "with some value", anything: "can go here"}
      ).should == application
    end

    it "should create a nil valued application when there is no information in the json" do
      application = double
      ATDIS::Models::Application.should_receive(:new).with({json_left_overs:{}, info: {},
        reference: {}}).and_return(application)

      ATDIS::Models::Application.interpret(info: {}, reference: {}).should == application
    end
  end

  describe "#extended" do
    it "should do no typecasting" do
      a = ATDIS::Models::Application.new(extended: {another_parameter: "with some value", anything: "can go here"})
      a.extended.should == {another_parameter: "with some value", anything: "can go here"}
    end
  end

  describe "#location=" do
    let(:a) { ATDIS::Models::Application.new }
    it "should type cast to a location" do
      location = double
      ATDIS::Models::Location.should_receive(:interpret).with(address: "123 Fourfivesix Street").and_return(location)
      a.locations = [{ address: "123 Fourfivesix Street" }]
      a.locations.should == [location]
    end

    it "should not cast when it's already a location" do
      l = ATDIS::Models::Location.new
      a.locations = [l]
      a.locations.should == [l]
    end
  end

  describe "#events" do
    let(:a) { ATDIS::Models::Application.new }
    it "should type cast to several events" do
      event1, event2 = double, double
      ATDIS::Models::Event.should_receive(:interpret).with(id: "event1").and_return(event1)
      ATDIS::Models::Event.should_receive(:interpret).with(id: "event2").and_return(event2)
      a.events = [ { id: "event1" }, { id: "event2" } ]
      a.events.should == [event1, event2]
    end
  end

  describe "#documents" do
    let(:a) { ATDIS::Models::Application.new }
    it "should type cast to several documents" do
      document1, document2 = double, double
      ATDIS::Models::Document.should_receive(:interpret).with(ref: "27B/6/a").and_return(document1)
      ATDIS::Models::Document.should_receive(:interpret).with(ref: "27B/6/b").and_return(document2)
      a.documents = [ { ref: "27B/6/a" }, { ref: "27B/6/b" } ]
      a.documents.should == [document1, document2]
    end
  end

  describe "#people" do
    let(:a) { ATDIS::Models::Application.new }
    it "should type cast to several people" do
      tuttle, buttle = double, double
      ATDIS::Models::Person.should_receive(:interpret).with(name: "Tuttle").and_return(tuttle)
      ATDIS::Models::Person.should_receive(:interpret).with(name: "Buttle").and_return(buttle)
      a.people = [ { name: "Tuttle" }, { name: "Buttle" } ]
      a.people.should == [tuttle, buttle]
    end
  end

  # TODO This should really be a test on the Model base class
  describe "#attribute_names" do
    it do
      # These are also ordered in a way that corresponds to the specification. Makes for easy reading by humans.
      ATDIS::Models::Application.attribute_names.should == [
        "info",
        "reference",
        "locations",
        "events",
        "documents",
        "people",
        "extended"
      ]
    end
  end

  describe "validations" do
    before :each do
      ATDIS::Models::Location.should_receive(:interpret).with("address").and_return(double(valid?: true))
      ATDIS::Models::Document.should_receive(:interpret).with("document").and_return(double(valid?: true))
      ATDIS::Models::Event.should_receive(:interpret).with("event").and_return(double(valid?: true))
    end

    let(:a) { ATDIS::Models::Application.new(
      info: ATDIS::Models::Info.new(
        dat_id: "DA2013-0381",
        development_type: "residential",
        last_modified_date: DateTime.new(2013,4,20,2,1,7),
        description: "New pool plus deck",
        authority: {
          ref:  "http://www.council.nsw.gov.au/atdis/1.0",
          name: "Example Council Shire Council"
        },
        lodgement_date: DateTime.new(2013,4,20,2,1,7),
        determination_date: DateTime.new(2013,6,20),
        determination_type: "Pending",
        status: "OPEN",
      ),
      reference: ATDIS::Models::Reference.new(
        more_info_url: URI.parse("http://foo.com/bar"),
      ),
      locations: ["address"],
      events: ["event"],
      documents: ["document"]
  ) }

    it { a.should be_valid }

    describe ".location" do
      it "should not be valid if the location is not valid" do
        l = double(valid?: false)
        ATDIS::Models::Location.should_receive(:interpret).with(foo: "some location data").and_return(l)
        a.locations = [{foo: "some location data"}]
        a.should_not be_valid
      end
    end

    describe "events" do
      it "has to be an array" do
        ATDIS::Models::Event.should_receive(:interpret).with(foo: "bar").and_return(double(valid?: true))
        a.events = {foo: "bar"}
        #a.events.should be_nil
        a.should_not be_valid
        a.errors.messages.should == {events: [ATDIS::ErrorMessage["should be an array", "4.3"]]}
      end

      it "can not be an empty array" do
        a.events = []
        a.should_not be_valid
        a.errors.messages.should == {events: [ATDIS::ErrorMessage.new("should not be an empty array", "4.3")]}
      end

      it "can not be empty" do
        a.events = nil
        a.should_not be_valid
        a.errors.messages.should == {events: [ATDIS::ErrorMessage["can't be blank", "4.3"]]}
      end
    end
  end
end
