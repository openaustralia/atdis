require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Event do
  it ".attribute_names" do
    ATDIS::Event.attribute_names.should == ["id", "date", "description", "event_type", "status"]
  end

  it ".id" do
    ATDIS::Event.interpret(id: "27B/6").id.should == "27B/6"
  end

  it ".date" do
    ATDIS::Event.interpret(date: "2013-06-18").date.should == DateTime.new(2013,6,18)
  end

  it ".description" do
    ATDIS::Event.interpret(description: "A very fine event").description.should == "A very fine event"
  end

  it ".event_type" do
    # TODO Is event_type always a string? ATDIS-1.0.3 doesn't say
    ATDIS::Event.interpret(event_type: "approval").event_type.should == "approval"
  end

  it ".status" do
    # TODO Is status always a string? ATDIS-1.0.3 doesn't say
    ATDIS::Event.interpret(status: "approved").status.should == "approved"
  end
end
