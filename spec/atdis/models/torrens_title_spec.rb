require "spec_helper"

describe ATDIS::Models::TorrensTitle do
  let(:l) do
    ATDIS::Models::TorrensTitle.new(
      lot: "10",
      section: "ABC",
      dpsp_id: "DP2013-0381"
    )
  end

  describe "dpsp_id" do
    it "can not be blank" do
      l.dpsp_id = ""
      expect(l).to_not be_valid
      expect(l.errors.messages).to eq(dpsp_id: [ATDIS::ErrorMessage["can't be blank", "4.3.3"]])
    end

    it "can be none but is not interpreted in any special way" do
      l.dpsp_id = "none"
      expect(l.dpsp_id).to eq "none"
      expect(l).to be_valid
    end
  end

  describe "section" do
    it "can not be blank" do
      l.section = ""
      expect(l).to_not be_valid
      expect(l.errors.messages).to eq(section: [ATDIS::ErrorMessage["can't be blank", "4.3.3"]])
    end

    it "can be null" do
      l.section = nil
      expect(l.section).to be_nil
      expect(l).to be_valid
    end
  end

  describe "lot" do
    it "can not be blank" do
      l.lot = ""
      expect(l).to_not be_valid
      expect(l.errors.messages).to eq(lot: [ATDIS::ErrorMessage["can't be blank", "4.3.3"]])
    end

    it "can be none but is not interpreted in any special way" do
      l.lot = "none"
      expect(l.lot).to eq "none"
      expect(l).to be_valid
    end
  end
end
