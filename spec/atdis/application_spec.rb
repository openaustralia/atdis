require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Application do
  before :each do
    @location = mock("Location")
    ATDIS::Location.should_receive(:interpret).with(
      :address => "123 Fourfivesix Street Neutral Bay NSW 2089",
      :land_title_ref => {
        :lot => "10",
        :section => "ABC",
        :dpsp_id => "DP2013-0381"
      }).and_return(@location)
    @application = ATDIS::Application.interpret(
      :info => {
        :dat_id => "DA2013-0381",
        :last_modified_date => "2013-04-20T02:01:07Z",
        :description => "New pool plus deck",
        :authority => "Example Council Shire Council",
        :lodgement_date => "2013-04-20T02:01:07Z",
        :determination_date => "2013-06-20",
        :status => "OPEN",
        :notification_start_date => "2013-04-20T02:01:07Z",
        :notification_end_date => "2013-05-20T02:01:07Z",
        :officer => "Ms Smith",
        # TODO: In ATDIS-1.0.3 it does not specify whether this is a float or a string and whether to include (or not) AUD or dollar sign
        # For the time being we'll just assume it's a free-form string
        :estimated_cost => "50,000"
      },
      :reference => {
        :more_info_url => "http://www.examplecouncil.nsw.gov.au/atdis/1.0/applications/DA2013-0381",
        :comments_url => "http://www.examplecouncil.nsw.gov.au/atdis/1.0/applications/DA2013-0381/comment"
      },
      :location => {
        :address => "123 Fourfivesix Street Neutral Bay NSW 2089",
        :land_title_ref => {
          :lot => "10",
          :section => "ABC",
          :dpsp_id => "DP2013-0381"
        }
      }
    )
  end

  it { @application.dat_id.should == "DA2013-0381" }
  it { @application.last_modified_date.should == DateTime.new(2013,4,20,2,1,7) }
  it { @application.description.should == "New pool plus deck" }
  it { @application.authority.should == "Example Council Shire Council" }
  it { @application.lodgement_date.should == DateTime.new(2013,4,20,2,1,7) }
  it { @application.determination_date.should == DateTime.new(2013,6,20) }
  it { @application.notification_start_date.should == DateTime.new(2013,4,20,2,1,7) }
  it { @application.notification_end_date.should == DateTime.new(2013,5,20,2,1,7) }
  it { @application.officer.should == "Ms Smith" }
  it { @application.estimated_cost.should == "50,000"}
  it { @application.status.should == "OPEN" }
  it { @application.more_info_url.should == URI.parse("http://www.examplecouncil.nsw.gov.au/atdis/1.0/applications/DA2013-0381") }
  it { @application.comments_url.should == URI.parse("http://www.examplecouncil.nsw.gov.au/atdis/1.0/applications/DA2013-0381/comment") }
  it { @application.location.should == @location }
end
