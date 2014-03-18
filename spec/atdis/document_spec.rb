require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Document do
  it ".attribute_names" do
    ATDIS::Document.attribute_names.should == ["ref", "title", "document_url"]
  end

  it ".ref" do
    ATDIS::Document.interpret(ref: "27B/6").ref.should == "27B/6"
  end

  it ".title" do
    ATDIS::Document.interpret(title: "Authorisation for Repairs").title.should == "Authorisation for Repairs"
  end

  it ".document_url" do
    ATDIS::Document.interpret(document_url: "http://foo.com/bar").document_url.should == URI.parse("http://foo.com/bar")
  end
end
