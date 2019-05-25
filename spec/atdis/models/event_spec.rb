# frozen_string_literal: true

require "spec_helper"

describe ATDIS::Models::Event do
  it ".attribute_names" do
    expect(ATDIS::Models::Event.attribute_names).to eq(
      %w[id timestamp description event_type status]
    )
  end

  it ".id" do
    expect(ATDIS::Models::Event.interpret({ id: "27B/6" }, "UTC").id).to eq "27B/6"
  end

  describe ".date" do
    it do
      expect(ATDIS::Models::Event.interpret({ timestamp: "2013-06-18" }, "UTC").timestamp).to eq(
        DateTime.new(2013, 6, 18)
      )
    end

    it do
      e = ATDIS::Models::Event.new({ description: "Something", id: "27B/6" }, "UTC")
      e.timestamp = "18 January 2013"
      expect(e).to_not be_valid
      expect(e.errors.messages).to eq(
        timestamp: [ATDIS::ErrorMessage["is not a valid date", "4.3.8"]]
      )
    end
  end

  it ".description" do
    expect(
      ATDIS::Models::Event.interpret({ description: "A very fine event" }, "UTC").description
    ).to eq "A very fine event"
  end

  it ".event_type" do
    # TODO: Is event_type always a string? ATDIS-1.0.3 doesn't say
    expect(
      ATDIS::Models::Event.interpret({ event_type: "approval" }, "UTC").event_type
    ).to eq "approval"
  end

  it ".status" do
    # TODO: Is status always a string? ATDIS-1.0.3 doesn't say
    expect(ATDIS::Models::Event.interpret({ status: "approved" }, "UTC").status).to eq "approved"
  end
end
