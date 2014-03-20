require "spec_helper"

describe ATDIS::Models::Event do
  it ".attribute_names" do
    ATDIS::Models::Event.attribute_names.should == ["id", "timestamp", "description", "event_type", "status"]
  end

  it ".id" do
    ATDIS::Models::Event.interpret(id: "27B/6").id.should == "27B/6"
  end

  it ".date" do
    ATDIS::Models::Event.interpret(timestamp: "2013-06-18").timestamp.should == DateTime.new(2013,6,18)
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
