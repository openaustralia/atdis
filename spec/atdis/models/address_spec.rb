# frozen_string_literal: true

require "spec_helper"

describe ATDIS::Models::Address do
  context "valid address" do
    let(:a) do
      ATDIS::Models::Address.new(
        {
          street: "123 Fourfivesix Street",
          suburb: "Neutral Bay",
          postcode: "2780",
          state: "NSW"
        },
        "UTC"
      )
    end

    it { expect(a).to be_valid }

    context "postcode that is too short" do
      before(:each) { a.postcode = "278" }
      it {
        expect(a).to_not be_valid
        expect(a.errors.messages).to eq(
          postcode: [ATDIS::ErrorMessage.new("is not a valid postcode", "4.3.3")]
        )
      }
    end
  end
end
