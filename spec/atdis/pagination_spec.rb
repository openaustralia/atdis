require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Pagination do
  context "total no_results is less than would be expected" do
    let (:pagination) { ATDIS::Pagination.new(current: 1, next: 2, per_page: 25, pages: 4, total_no_results: 75)}
    it do
      pagination.should_not be_valid
      pagination.errors.messages.should == {total_no_results: [ATDIS::ErrorMessage["could fit into a smaller number of pages", "6.5"]]}
    end
  end

  context "total_no_results is larger than would be expected" do
    let(:pagination) { ATDIS::Pagination.new(current: 1, next: 2, per_page: 25, pages: 4, total_no_results: 101)}
    it do
      pagination.should_not be_valid
      pagination.errors.messages.should == {total_no_results: [ATDIS::ErrorMessage["is larger than can be retrieved through paging", "6.5"]]}
    end
  end

  context "current page is zero" do
    let(:pagination) { ATDIS::Pagination.new(pages: 1, per_page: 25, total_no_results: 2) }
    before :each do
      pagination.current = 0
      pagination.next = 1
    end
    it do
      pagination.should_not be_valid
      pagination.errors.messages.should == {current: [ATDIS::ErrorMessage["can not be less than 1", "6.5"]]}
    end
  end

  context "current page is larger than the number of pages" do
    let(:pagination) { ATDIS::Pagination.new(pages: 1, per_page: 25, total_no_results: 2) }
    before :each do
      pagination.current = 2
      pagination.previous = 1
      pagination.next = 3
      pagination.pages = 1
    end
    it do
      pagination.should_not be_valid
      pagination.errors.messages.should == {current: [ATDIS::ErrorMessage["is larger than the number of pages", "6.5"]]}
    end
  end

  context "next page number is not nil but on last page" do
    let(:pagination) { ATDIS::Pagination.new(pages: 1, per_page: 25, total_no_results: 2) }
    before :each do
      pagination.previous = 3
      pagination.current = 4
      pagination.next = 5
      pagination.total_no_results = 100
      pagination.pages = 4
    end
    it do
      pagination.should_not be_valid
      pagination.errors.messages.should == {next: [ATDIS::ErrorMessage["should be null if on the last page", "6.5"]]}
    end
  end

  context "next page number is nil but not on last page" do
    let(:pagination) { ATDIS::Pagination.new(pages: 1, per_page: 25, total_no_results: 2) }
    before :each do
      pagination.current = 4
      pagination.previous = 3
      pagination.next = nil
      pagination.total_no_results = 140
      pagination.pages = 6
    end
    it do
      pagination.should_not be_valid
      pagination.errors.messages.should == {next: [ATDIS::ErrorMessage["can't be null if not on the last page", "6.5"]]}
    end
  end

  context "next page number is pointing to a weird page number" do
    let(:pagination) { ATDIS::Pagination.new(pages: 1, per_page: 25, total_no_results: 2, current: 1) }
    before :each do
      pagination.next = 5
      pagination.total_no_results = 50
      pagination.pages = 2
    end
    it do
      pagination.should_not be_valid
      pagination.errors.messages.should == {next: [ATDIS::ErrorMessage["should be one greater than current page number or null if last page", "6.5"]]}
    end
  end

  context "previous page number not nil but on first page" do
    let(:pagination) { ATDIS::Pagination.new(pages: 1, per_page: 25, total_no_results: 2, current: 1) }
    before :each do
      pagination.current = 1
      pagination.next = 2
      pagination.previous = 0
      pagination.total_no_results = 240
      pagination.pages = 10
    end
    it do
      pagination.should_not be_valid
      pagination.errors.messages.should == {previous: [ATDIS::ErrorMessage["should be null if on the first page", "6.5"]]}
    end
  end

  context "previous page number if nil but not on first page" do
    let(:pagination) { ATDIS::Pagination.new(pages: 1, per_page: 25, total_no_results: 2, current: 1) }
    before :each do
      pagination.current = 4
      pagination.next = 5
      pagination.previous = nil
      pagination.total_no_results = 240
      pagination.pages = 10
    end
    it do
      pagination.should_not be_valid
      pagination.errors.messages.should == {previous: [ATDIS::ErrorMessage["can't be null if not on the first page", "6.5"]]}
    end
  end

  context "previous page number is pointing to a weird page number" do
    let(:pagination) { ATDIS::Pagination.new(pages: 1, per_page: 25, total_no_results: 2, current: 1) }
    before :each do
      pagination.previous = 5
      pagination.current = 2
      pagination.total_no_results = 50
      pagination.pages = 2
    end
    it do
      pagination.should_not be_valid
      pagination.errors.messages.should == {previous: [ATDIS::ErrorMessage["should be one less than current page number or null if first page", "6.5"]]}
      pagination.json_errors.should == [[{previous: 5}, [ATDIS::ErrorMessage["previous should be one less than current page number or null if first page", "6.5"]]]]
    end
  end


end
