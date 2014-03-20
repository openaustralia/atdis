require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Models::Person do
  it ".attribute_names" do
    ATDIS::Models::Person.attribute_names.should == ["name", "role", "contact"]
  end

  it ".name" do
    ATDIS::Models::Person.interpret(name: "Tuttle").name.should == "Tuttle"
  end

  it ".role" do
    ATDIS::Models::Person.interpret(role: "Heating Engineer").role.should == "Heating Engineer"
  end

  it ".contact" do
    ATDIS::Models::Person.interpret(contact: "94-FLUSH").contact.should == "94-FLUSH"
  end
end
