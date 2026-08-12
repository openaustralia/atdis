# frozen_string_literal: true

require "spec_helper"

describe ATDIS::Models::Response do
  it "is valid with a valid application" do
    application = double(valid?: true)
    expect(ATDIS::Models::Application).to receive(:interpret)
      .with("application", "UTC").and_return(application)

    response = ATDIS::Models::Response.interpret({ application: "application" }, "UTC")
    expect(response).to be_valid
  end

  it "is not valid when the application is not valid" do
    application = double(valid?: false)
    expect(ATDIS::Models::Application).to receive(:interpret)
      .with("application", "UTC").and_return(application)

    response = ATDIS::Models::Response.interpret({ application: "application" }, "UTC")
    expect(response).to_not be_valid
  end

  it "is not valid without an application" do
    response = ATDIS::Models::Response.interpret({}, "UTC")
    expect(response).to_not be_valid
  end
end
