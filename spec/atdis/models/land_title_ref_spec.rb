# frozen_string_literal: true

require "spec_helper"

describe ATDIS::Models::LandTitleRef do
  context "torrens" do
    before(:each) do
      m = double
      expect(ATDIS::Models::TorrensTitle).to receive(:interpret).with(
        { lot: "10" },
        "UTC"
      ).and_return(m)
      expect(m).to receive(:valid?).and_return(true)
    end
    let(:l) { ATDIS::Models::LandTitleRef.new({ torrens: { lot: "10" } }, "UTC") }
    it { expect(l).to be_valid }
  end

  context "other" do
    let(:l) { ATDIS::Models::LandTitleRef.new({ other: { some: "foo", random: "stuff" } }, "UTC") }
    it { expect(l).to be_valid }
  end

  context "no torrens or other" do
    let(:l) { ATDIS::Models::LandTitleRef.new({}, "UTC") }
    it {
      expect(l).to_not be_valid
      expect(l.errors.messages).to eq(
        torrens: [ATDIS::ErrorMessage.new("or other needs be present", "4.3.3")]
      )
    }
  end

  context "both torrens and other" do
    before(:each) do
      m = double
      expect(ATDIS::Models::TorrensTitle).to(
        receive(:interpret).with({ lot: "10" }, "UTC").and_return(m)
      )
      expect(m).to receive(:valid?).and_return(true)
    end
    let(:l) do
      ATDIS::Models::LandTitleRef.new(
        { torrens: { lot: "10" }, other: { some: "foo", random: "stuff" } },
        "UTC"
      )
    end
    it {
      expect(l).to_not be_valid
      expect(l.errors.messages).to eq(
        torrens: [ATDIS::ErrorMessage.new("and other can't both be present", "4.3.3")]
      )
    }
  end
end
