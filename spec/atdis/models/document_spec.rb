# frozen_string_literal: true

require "spec_helper"

describe ATDIS::Models::Document do
  it ".attribute_names" do
    expect(ATDIS::Models::Document.attribute_names).to eq %w[ref title document_url]
  end

  it ".ref" do
    expect(ATDIS::Models::Document.interpret(ref: "27B/6").ref).to eq "27B/6"
  end

  it ".title" do
    expect(ATDIS::Models::Document.interpret(title: "Authorisation for Repairs").title).to eq(
      "Authorisation for Repairs"
    )
  end

  it ".document_url" do
    expect(
      ATDIS::Models::Document.interpret(document_url: "http://foo.com/bar").document_url
    ).to eq(
      URI.parse("http://foo.com/bar")
    )
  end
end
