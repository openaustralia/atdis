require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Pagination do
  context "valid pagination" do
    let (:pagination) { ATDIS::Pagination.new(
      previous: nil, current: 1, next: 2, per_page: 25, pages: 4, total_no_results: 90
    )}
    it do
      pagination.should be_valid
    end
  end

  context "current is not set" do
    let (:pagination) { ATDIS::Pagination.new(
      previous: nil, current: nil, next: 2, per_page: 25, pages: 4, total_no_results: 90
    )}
    it do
      pagination.should_not be_valid
      pagination.errors.messages.should == {current: [ATDIS::ErrorMessage["should be present if pagination is being used", "6.5"]]}
    end
  end

  context "per_page is not set" do
    let (:pagination) { ATDIS::Pagination.new(
      previous: nil, current: 1, next: 2, per_page: nil, pages: 4, total_no_results: 90
    )}
    it do
      pagination.should_not be_valid
      pagination.errors.messages.should == {per_page: [ATDIS::ErrorMessage["should be present if pagination is being used", "6.5"]]}
    end
  end

  context "total_not_results is not set" do
    let (:pagination) { ATDIS::Pagination.new(
      previous: nil, current: 1, next: 2, per_page: 25, pages: 4, total_no_results: nil
    )}
    it do
      pagination.should_not be_valid
      pagination.errors.messages.should == {total_no_results: [ATDIS::ErrorMessage["should be present if pagination is being used", "6.5"]]}
    end
  end

  context "pages is not set" do
    let (:pagination) { ATDIS::Pagination.new(
      previous: nil, current: 1, next: 2, per_page: 25, pages: nil, total_no_results: 90
    )}
    it do
      pagination.should_not be_valid
      pagination.errors.messages.should == {pages: [ATDIS::ErrorMessage["should be present if pagination is being used", "6.5"]]}
    end
  end

  context "total no_results is less than would be expected" do
    let (:pagination) { ATDIS::Pagination.new(
      previous: nil, current: 1, next: 2, per_page: 25, pages: 4, total_no_results: 75
    )}
    it do
      pagination.should_not be_valid
      pagination.errors.messages.should == {total_no_results: [ATDIS::ErrorMessage["could fit into a smaller number of pages", "6.5"]]}
    end
  end

  context "total_no_results is larger than would be expected" do
    let(:pagination) { ATDIS::Pagination.new(
      previous: nil, current: 1, next: 2, per_page: 25, pages: 4, total_no_results: 101
    )}
    it do
      pagination.should_not be_valid
      pagination.errors.messages.should == {total_no_results: [ATDIS::ErrorMessage["is larger than can be retrieved through paging", "6.5"]]}
    end
  end

  context "current page is zero" do
    let(:pagination) { ATDIS::Pagination.new(
      previous: nil, current: 0, next: 1, pages: 1, per_page: 25, total_no_results: 2
    ) }
    it do
      pagination.should_not be_valid
      pagination.errors.messages.should == {current: [ATDIS::ErrorMessage["can not be less than 1", "6.5"]]}
    end
  end

  context "current page is larger than the number of pages" do
    let(:pagination) { ATDIS::Pagination.new(
      previous: nil, previous: 1, current: 2, next: 3, pages: 1, per_page: 25, total_no_results: 2
    ) }
    it do
      pagination.should_not be_valid
      pagination.errors.messages.should == {current: [ATDIS::ErrorMessage["is larger than the number of pages", "6.5"]]}
    end
  end

  context "next page number is not nil but on last page" do
    let(:pagination) { ATDIS::Pagination.new(
      previous: 3, current: 4, next: 5, pages: 4, per_page: 25, total_no_results: 100
    ) }
    it do
      pagination.should_not be_valid
      pagination.errors.messages.should == {next: [ATDIS::ErrorMessage["should be null if on the last page", "6.5"]]}
    end
  end

  context "next page number is nil but not on last page" do
    let(:pagination) { ATDIS::Pagination.new(
      previous: 3, current: 4, next: nil, pages: 6, per_page: 25, total_no_results: 140
    ) }
    it do
      pagination.should_not be_valid
      pagination.errors.messages.should == {next: [ATDIS::ErrorMessage["can't be null if not on the last page", "6.5"]]}
    end
  end

  context "next page number is pointing to a weird page number" do
    let(:pagination) { ATDIS::Pagination.new(
      previous: nil, current: 1, next: 5, pages: 2, per_page: 25, total_no_results: 50
    ) }
    it do
      pagination.should_not be_valid
      pagination.errors.messages.should == {next: [ATDIS::ErrorMessage["should be one greater than current page number or null if last page", "6.5"]]}
    end
  end

  context "previous page number not nil but on first page" do
    let(:pagination) { ATDIS::Pagination.new(
      previous: 0, current: 1, next: 2, pages: 10, per_page: 25, total_no_results: 240
    ) }
    it do
      pagination.should_not be_valid
      pagination.errors.messages.should == {previous: [ATDIS::ErrorMessage["should be null if on the first page", "6.5"]]}
    end
  end

  context "previous page number if nil but not on first page" do
    let(:pagination) { ATDIS::Pagination.new(
      previous: nil, current: 4, next: 5, pages: 10, per_page: 25, total_no_results: 240
    ) }
    it do
      pagination.should_not be_valid
      pagination.errors.messages.should == {previous: [ATDIS::ErrorMessage["can't be null if not on the first page", "6.5"]]}
    end
  end

  context "previous page number is pointing to a weird page number" do
    let(:pagination) { ATDIS::Pagination.new(
      previous: 5, current: 2, next: nil, pages: 2, per_page: 25, total_no_results: 50
    ) }
    it do
      pagination.should_not be_valid
      pagination.errors.messages.should == {previous: [ATDIS::ErrorMessage["should be one less than current page number or null if first page", "6.5"]]}
      pagination.json_errors.should == [[{previous: 5}, [ATDIS::ErrorMessage["previous should be one less than current page number or null if first page", "6.5"]]]]
    end
  end
end
