require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Application do

  describe ".interpret" do
    context "valid" do
      let(:location) { mock }
      let(:event1) { mock }
      let(:event2) { mock }
      let(:document1) { mock }
      let(:document2) { mock }
      let(:tuttle) { mock }
      let(:buttle) { mock }

      let(:a) do
        ATDIS::Application.interpret(
          :info => {
            :dat_id => "DA2013-0381",
            :last_modified_date => "2013-04-20T02:01:07Z",
            :description => "New pool plus deck",
            :authority => "Example Council Shire Council",
            :lodgement_date => "2013-04-20T02:01:07Z",
            :determination_date => "2013-06-20",
            :notification_start_date => "2013-04-20T02:01:07Z",
            :notification_end_date => "2013-05-20T02:01:07Z",
            :officer => "Ms Smith",
            # TODO: In ATDIS-1.0.3 it does not specify whether this is a float or a string
            # and whether to include (or not) AUD or dollar sign. For the time being we'll
            # just assume it's a free-form string
            :estimated_cost => "50,000",
            :status => "OPEN"
          },
          :reference => {
            :more_info_url => "http://foo.com/bar",
            :comments_url => "http://foo.com/comment"
          },
          :location => { :address => "123 Fourfivesix Street" },
          :events => [ { :id => "event1" }, { :id => "event2" } ],
          :documents => [ { :ref => "27B/6/a" }, { :ref => "27B/6/b" } ],
          :people => [ { :name => "Tuttle" }, { :name => "Buttle" } ]
        )
      end

      before :each do
        ATDIS::Location.should_receive(:interpret).with(:address => "123 Fourfivesix Street").and_return(location)
        ATDIS::Event.should_receive(:interpret).with(:id => "event1").and_return(event1)
        ATDIS::Event.should_receive(:interpret).with(:id => "event2").and_return(event2)
        ATDIS::Document.should_receive(:interpret).with(:ref => "27B/6/a").and_return(document1)
        ATDIS::Document.should_receive(:interpret).with(:ref => "27B/6/b").and_return(document2)
        ATDIS::Person.should_receive(:interpret).with(:name => "Tuttle").and_return(tuttle)
        ATDIS::Person.should_receive(:interpret).with(:name => "Buttle").and_return(buttle)
      end
      
      it { a.dat_id.should == "DA2013-0381" }
      it { a.last_modified_date.should == DateTime.new(2013,4,20,2,1,7) }
      it { a.description.should == "New pool plus deck" }
      it { a.authority.should == "Example Council Shire Council" }
      it { a.lodgement_date.should == DateTime.new(2013,4,20,2,1,7) }
      it { a.determination_date.should == DateTime.new(2013,6,20) }
      it { a.notification_start_date.should == DateTime.new(2013,4,20,2,1,7) }
      it { a.notification_end_date.should == DateTime.new(2013,5,20,2,1,7) }
      it { a.officer.should == "Ms Smith" }
      it { a.estimated_cost.should == "50,000" }
      it { a.status.should == "OPEN" }
      it { a.more_info_url.should == URI.parse("http://foo.com/bar") }
      it { a.comments_url.should == URI.parse("http://foo.com/comment") }
      it { a.location.should == location }
      it { a.events.should == [event1, event2] }
      it { a.documents.should == [document1, document2] }
      it { a.people.should == [tuttle, buttle] }
    end

    context "not valid" do
      let(:a) { ATDIS::Application.interpret(:info => {}, :reference => {}) }
      it { a.dat_id.should be_nil }
      it { a.last_modified_date.should be_nil }
      it { a.description.should be_nil }
      it { a.authority.should be_nil }
      it { a.lodgement_date.should be_nil }
      it { a.determination_date.should be_nil }
      it { a.notification_start_date.should be_nil }
      it { a.notification_end_date.should be_nil }
      it { a.officer.should be_nil }
      it { a.estimated_cost.should be_nil }
      it { a.status.should be_nil }
      it { a.more_info_url.should be_nil }
      it { a.comments_url.should be_nil }
      it { a.location.should be_nil }
      it { a.events.should be_nil }
      it { a.documents.should be_nil }
      it { a.people.should be_nil }
    end
  end

  describe "validations" do
    let(:a) { ATDIS::Application.new(:dat_id => "DA2013-0381", :last_modified_date => "2013-04-20T02:01:07Z") }

    it { a.should be_valid }

    it ".dat_id" do
      a.dat_id = nil
      a.should_not be_valid
      a.errors.messages.should == {:dat_id => ["can't be blank"]}
    end

    it ".last_modified_date" do
      a.last_modified_date = nil
      a.should_not be_valid
      a.errors.messages.should == {:last_modified_date => ["can't be blank"]}
    end
  end

end
