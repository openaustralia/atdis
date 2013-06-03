require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module ATDIS
  class Application
    def self.parse(text)
      Application.new
    end

    def dat_id
      "DA2013-0381"
    end
  end
end

describe ATDIS::Application do
  describe "#dat_id" do
    it "should correctly interpret a json snippet in the correct format" do
      application = ATDIS::Application.parse <<-EOF
{
  “info”: {
    "dat_id": "DA2013-0381",
    "description": "New pool plus deck",
    "authority": "Example Council Shire Council",
    "lodgement_date": "2013-04-20T02:01:07Z",
    "determination_date": "2013-06-20T02:01:07Z",
    "notification_start_date": "2013-04-20T02:01:07Z",
    "notification_end_date": "2013-05-20T02:01:07Z",
    "status": "OPEN"
  },
  "reference": {
    "more_info_url": "http://www.examplecouncil.nsw.gov.au/atdis/1.0/applications/DA2013-0381"
  },
  "location": {
    "address": "123 Fourfivesix Street Neutral Bay NSW 2089",
    "land_title_ref": {
      "lot": "10",
      "section": "ABC",
      "dpsp_id": "DP2013-0381"
    }
  },
}
      EOF
      application.dat_id.should == "DA2013-0381"
    end
  end
end
