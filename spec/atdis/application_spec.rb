require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Application do

  describe ".dat_id" do
    context "valid" do
      let(:a) { ATDIS::Application.interpret(:info => {:dat_id => "DA2013-0381", :last_modified_date => "2013-04-20T02:01:07Z"}) }
      it { a.dat_id.should == "DA2013-0381" }
      it { a.should be_valid }
    end

    context "not valid" do
      let(:a) { ATDIS::Application.interpret(:info => {:last_modified_date => "2013-04-20T02:01:07Z"}) }
      it { a.dat_id.should be_nil }
      it do
        a.should_not be_valid
        a.errors.messages.should == {:dat_id => ["can't be blank"]}
      end
    end
  end

  describe ".last_modified_date" do
    context "valid" do
      let(:a) { ATDIS::Application.interpret(:info => {:dat_id => "DA2013-0381", :last_modified_date => "2013-04-20T02:01:07Z"}) }
      it { a.last_modified_date.should == DateTime.new(2013,4,20,2,1,7) }
      it { a.should be_valid }
    end

    context "not valid" do
      let(:a) { ATDIS::Application.interpret(:info => {:dat_id => "DA2013-0381"}) }
      it { a.last_modified_date.should be_nil }
      it do
        a.should_not be_valid
        a.errors.messages.should == {:last_modified_date => ["can't be blank"]}
      end

    end
  end

  it ".description" do
    ATDIS::Application.interpret(:info => {:description => "New pool plus deck"}).description.should == "New pool plus deck"
  end

  it ".authority" do
    ATDIS::Application.interpret(:info => {:authority => "Example Council Shire Council"}).authority.should == "Example Council Shire Council"
  end

  it ".lodgement_date" do
    ATDIS::Application.interpret(:info => {:lodgement_date => "2013-04-20T02:01:07Z"}).lodgement_date.should == DateTime.new(2013,4,20,2,1,7)
  end

  it ".determination_date" do
    ATDIS::Application.interpret(:info => {:determination_date => "2013-06-20"}).determination_date.should == DateTime.new(2013,6,20)
  end

  it ".notification_start_date" do
    ATDIS::Application.interpret(:info => {:notification_start_date => "2013-04-20T02:01:07Z"}).notification_start_date.should == DateTime.new(2013,4,20,2,1,7)
  end

  it "notification_end_date" do
    ATDIS::Application.interpret(:info => {:notification_end_date => "2013-05-20T02:01:07Z"}).notification_end_date.should == DateTime.new(2013,5,20,2,1,7)
  end

  it ".officer" do
    ATDIS::Application.interpret(:info => {:officer => "Ms Smith"}).officer.should == "Ms Smith"
  end

  it ".estimated_cost" do
    # TODO: In ATDIS-1.0.3 it does not specify whether this is a float or a string and whether to include (or not) AUD or dollar sign
    # For the time being we'll just assume it's a free-form string
    ATDIS::Application.interpret(:info => {:estimated_cost => "50,000"}).estimated_cost.should == "50,000"
  end

  it ".status" do
    ATDIS::Application.interpret(:info => {:status => "OPEN"}).status.should == "OPEN"
  end

  it ".more_info_url" do
    ATDIS::Application.interpret(:reference => {:more_info_url => "http://foo.com/bar"}).more_info_url.should == URI.parse("http://foo.com/bar")
  end

  it "comments_url" do
    ATDIS::Application.interpret(:reference => {:comments_url => "http://foo.com/comment"}).comments_url.should == URI.parse("http://foo.com/comment")
  end

  it ".location" do
    location = mock
    ATDIS::Location.should_receive(:interpret).with(:address => "123 Fourfivesix Street").and_return(location)
    application = ATDIS::Application.interpret(
      :location => {
        :address => "123 Fourfivesix Street"
      }
    )
    application.location.should == location
  end

  it ".events" do
    event1 = mock
    event2 = mock
    ATDIS::Event.should_receive(:interpret).with(:id => "event1").and_return(event1)
    ATDIS::Event.should_receive(:interpret).with(:id => "event2").and_return(event2)
    application = ATDIS::Application.interpret(
      :events => [
        {
          :id => "event1"
        },
        {
          :id => "event2"
        }
      ]
    )
    application.events.should == [event1, event2]
  end

  it ".documents" do
    document1 = mock
    document2 = mock
    ATDIS::Document.should_receive(:interpret).with(:ref => "27B/6/a").and_return(document1)
    ATDIS::Document.should_receive(:interpret).with(:ref => "27B/6/b").and_return(document2)
    application = ATDIS::Application.interpret(
      :documents => [
        {
          :ref => "27B/6/a"
        },
        {
          :ref => "27B/6/b"
        }
      ]
    )
    application.documents.should == [document1, document2]
  end

  it ".people" do
    tuttle = mock
    buttle = mock
    ATDIS::Person.should_receive(:interpret).with(:name => "Tuttle").and_return(tuttle)
    ATDIS::Person.should_receive(:interpret).with(:name => "Buttle").and_return(buttle)

    application = ATDIS::Application.interpret(
      :people => [
        {
          :name => "Tuttle"
        },
        {
          :name => "Buttle"
        }
      ]
    )
    application.people.should == [tuttle, buttle]
  end
end
