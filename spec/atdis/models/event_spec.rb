require "spec_helper"

describe ATDIS::Models::Event do
  it ".attribute_names" do
    ATDIS::Models::Event.attribute_names.should == ["id", "timestamp", "description", "event_type", "status"]
  end

  it ".id" do
    ATDIS::Models::Event.interpret(id: "27B/6").id.should == "27B/6"
  end

  describe ".date" do
    it do
      ATDIS::Models::Event.interpret(timestamp: "2013-06-18").timestamp.should == DateTime.new(2013,6,18)
    end

    it do
      e = ATDIS::Models::Event.new(description: "Something", id: "27B/6")
      e.timestamp = "18 January 2013"
      e.should_not be_valid
      e.errors.messages.should == {timestamp: [ATDIS::ErrorMessage["is not a valid date", "4.3.8"]]}
    end
  end

  it ".description" do
    ATDIS::Models::Event.interpret(description: "A very fine event").description.should == "A very fine event"
  end

  it ".event_type" do
    # TODO Is event_type always a string? ATDIS-1.0.3 doesn't say
    ATDIS::Models::Event.interpret(event_type: "approval").event_type.should == "approval"
  end

  it ".status" do
    # TODO Is status always a string? ATDIS-1.0.3 doesn't say
    ATDIS::Models::Event.interpret(status: "approved").status.should == "approved"
  end
end
