# frozen_string_literal: true

require "spec_helper"

describe ATDIS::Models::Application do
  context "extra parameter in json" do
    it "should not be valid" do
      expect(ATDIS::Models::Location).to receive(:interpret).with("location", "UTC")
                                                            .and_return(double(valid?: true))
      expect(ATDIS::Models::Document).to receive(:interpret).with("document", "UTC")
                                                            .and_return(double(valid?: true))
      expect(ATDIS::Models::Event).to receive(:interpret).with("event", "UTC")
                                                         .and_return(double(valid?: true))

      a = ATDIS::Models::Application.interpret(
        {
          info: {
            dat_id: "DA2013-0381",
            development_type: "residential",
            application_type: "DA",
            last_modified_date: "2013-04-20T02:01:07Z",
            description: "New pool plus deck",
            authority: {
              ref: "http://www.council.nsw.gov.au/atdis/1.0",
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
        },
        "UTC"
      )
      expect(a).to_not be_valid
      expect(a.errors.messages).to eq(
        json: [
          ATDIS::ErrorMessage['Unexpected parameters in json data: {"foo":"bar"}', "4"]
        ]
      )
    end
  end

  describe ".interpret" do
    it "should parse the json and create an application object" do
      application = double

      expect(ATDIS::Models::Application).to receive(:new).with(
        {
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
            status: "OPEN"
          },
          reference: {
            more_info_url: "http://foo.com/bar",
            comments_url: "http://foo.com/comment"
          },
          locations: [{ address: "123 Fourfivesix Street" }],
          events: [{ id: "event1" }, { id: "event2" }],
          documents: [{ ref: "27B/6/a" }, { ref: "27B/6/b" }],
          people: [{ name: "Tuttle" }, { name: "Buttle" }],
          extended: { another_parameter: "with some value", anything: "can go here" },
          json_left_overs: {}
        },
        "UTC"
      ).and_return(application)

      expect(
        ATDIS::Models::Application.interpret(
          {
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
            events: [{ id: "event1" }, { id: "event2" }],
            documents: [{ ref: "27B/6/a" }, { ref: "27B/6/b" }],
            people: [{ name: "Tuttle" }, { name: "Buttle" }],
            extended: { another_parameter: "with some value", anything: "can go here" }
          },
          "UTC"
        )
      ).to eq application
    end

    it "should create a nil valued application when there is no information in the json" do
      application = double
      expect(ATDIS::Models::Application).to receive(:new)
        .with({ json_left_overs: {}, info: {}, reference: {} }, "UTC").and_return(application)

      expect(
        ATDIS::Models::Application.interpret({ info: {}, reference: {} }, "UTC")
      ).to eq application
    end
  end

  describe "#extended" do
    it "should do no typecasting" do
      a = ATDIS::Models::Application.new(
        { extended: { another_parameter: "with some value", anything: "can go here" } },
        "UTC"
      )
      expect(a.extended).to eq(another_parameter: "with some value", anything: "can go here")
    end
  end

  describe "#location=" do
    let(:a) { ATDIS::Models::Application.new({}, "UTC") }
    it "should type cast to a location" do
      location = double
      expect(ATDIS::Models::Location).to receive(:interpret).with(
        { address: "123 Fourfivesix Street" },
        "UTC"
      ).and_return(location)
      a.locations = [{ address: "123 Fourfivesix Street" }]
      expect(a.locations).to eq [location]
    end

    it "should not cast when it's already a location" do
      l = ATDIS::Models::Location.new({}, "UTC")
      a.locations = [l]
      expect(a.locations).to eq [l]
    end
  end

  describe "#events" do
    let(:a) { ATDIS::Models::Application.new({}, "UTC") }
    it "should type cast to several events" do
      event1 = double
      event2 = double
      expect(ATDIS::Models::Event).to receive(:interpret).with(
        { id: "event1" },
        "UTC"
      ).and_return(event1)
      expect(ATDIS::Models::Event).to receive(:interpret).with(
        { id: "event2" },
        "UTC"
      ).and_return(event2)
      a.events = [{ id: "event1" }, { id: "event2" }]
      expect(a.events).to eq [event1, event2]
    end
  end

  describe "#documents" do
    let(:a) { ATDIS::Models::Application.new({}, "UTC") }
    it "should type cast to several documents" do
      document1 = double
      document2 = double
      expect(ATDIS::Models::Document).to receive(:interpret).with({ ref: "27B/6/a" }, "UTC")
                                                            .and_return(document1)
      expect(ATDIS::Models::Document).to receive(:interpret).with({ ref: "27B/6/b" }, "UTC")
                                                            .and_return(document2)
      a.documents = [{ ref: "27B/6/a" }, { ref: "27B/6/b" }]
      expect(a.documents).to eq [document1, document2]
    end
  end

  describe "#people" do
    let(:a) { ATDIS::Models::Application.new({}, "UTC") }
    it "should type cast to several people" do
      tuttle = double
      buttle = double
      expect(ATDIS::Models::Person).to(
        receive(:interpret).with({ name: "Tuttle" }, "UTC").and_return(tuttle)
      )
      expect(ATDIS::Models::Person).to(
        receive(:interpret).with({ name: "Buttle" }, "UTC").and_return(buttle)
      )
      a.people = [{ name: "Tuttle" }, { name: "Buttle" }]
      expect(a.people).to eq [tuttle, buttle]
    end
  end

  # TODO: This should really be a test on the Model base class
  describe "#attribute_names" do
    it do
      # These are also ordered in a way that corresponds to the specification.
      # Makes for easy reading by humans.
      expect(ATDIS::Models::Application.attribute_names).to eq %w[
        info
        reference
        locations
        events
        documents
        people
        extended
      ]
    end
  end

  describe "validations" do
    before :each do
      expect(ATDIS::Models::Location).to receive(:interpret).with("address", "UTC")
                                                            .and_return(double(valid?: true))
      expect(ATDIS::Models::Document).to receive(:interpret).with("document", "UTC")
                                                            .and_return(double(valid?: true))
      expect(ATDIS::Models::Event).to receive(:interpret).with("event", "UTC")
                                                         .and_return(double(valid?: true))
    end

    let(:a) do
      ATDIS::Models::Application.new(
        {
          info: ATDIS::Models::Info.new(
            {
              dat_id: "DA2013-0381",
              development_type: "residential",
              application_type: "DA",
              last_modified_date: DateTime.new(2013, 4, 20, 2, 1, 7),
              description: "New pool plus deck",
              authority: {
                ref: "http://www.council.nsw.gov.au/atdis/1.0",
                name: "Example Council Shire Council"
              },
              lodgement_date: DateTime.new(2013, 4, 20, 2, 1, 7),
              determination_date: DateTime.new(2013, 6, 20),
              determination_type: "Pending",
              status: "OPEN"
            },
            "UTC"
          ),
          reference: ATDIS::Models::Reference.new(
            {
              more_info_url: URI.parse("http://foo.com/bar")
            },
            "UTC"
          ),
          locations: ["address"],
          events: ["event"],
          documents: ["document"]
        },
        "UTC"
      )
    end

    it { expect(a).to be_valid }

    describe ".location" do
      it "should not be valid if the location is not valid" do
        l = double(valid?: false)
        expect(ATDIS::Models::Location).to(
          receive(:interpret).with({ foo: "some location data" }, "UTC").and_return(l)
        )
        a.locations = [{ foo: "some location data" }]
        expect(a).to_not be_valid
      end
    end

    describe "events" do
      it "has to be an array" do
        expect(ATDIS::Models::Event).to receive(:interpret).with({ foo: "bar" }, "UTC")
                                                           .and_return(double(valid?: true))
        a.events = { foo: "bar" }
        # expect(a.events).to be_nil
        expect(a).to_not be_valid
        expect(a.errors.messages).to eq(
          events: [ATDIS::ErrorMessage["should be an array", "4.3"]]
        )
      end

      it "can not be an empty array" do
        a.events = []
        expect(a).to_not be_valid
        expect(a.errors.messages).to eq(
          events: [ATDIS::ErrorMessage.new("should not be an empty array", "4.3")]
        )
      end

      it "can not be empty" do
        a.events = nil
        expect(a).to_not be_valid
        expect(a.errors.messages).to eq(
          events: [ATDIS::ErrorMessage["can't be blank", "4.3"]]
        )
      end
    end

    describe "documents" do
      it "can be an empty array" do
        a.documents = []
        expect(a).to be_valid
      end
    end
  end
end
