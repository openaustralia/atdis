# frozen_string_literal: true

require "spec_helper"

describe ATDIS::Models::Person do
  it ".attribute_names" do
    expect(ATDIS::Models::Person.attribute_names).to eq %w[name role contact]
  end

  it ".name" do
    expect(ATDIS::Models::Person.interpret({ name: "Tuttle" }, "UTC").name).to eq "Tuttle"
  end

  it ".role" do
    expect(
      ATDIS::Models::Person.interpret({ role: "Heating Engineer" }, "UTC").role
    ).to eq "Heating Engineer"
  end

  it ".contact" do
    expect(ATDIS::Models::Person.interpret({ contact: "94-FLUSH" }, "UTC").contact).to eq "94-FLUSH"
  end
end
