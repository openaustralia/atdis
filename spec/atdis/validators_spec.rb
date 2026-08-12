# frozen_string_literal: true

require "spec_helper"

# A minimal model for exercising the validators without a spec_section,
# where the error messages are plain strings rather than ErrorMessages
class ValidatorTestModel
  include ActiveModel::Validations
  include ATDIS::Validators

  attr_accessor :url, :urls, :list, :filled_list, :geo, :required

  # The validators look at the raw value before type casting
  attr_writer :url_before_type_cast, :geo_before_type_cast, :required_before_type_cast

  validates :url, http_url: true
  validates :urls, array_http_url: true
  validates :list, array: true
  validates :filled_list, filled_array: true
  validates :geo, geo_json: true
  validates :required, presence_before_type_cast: true

  def url_before_type_cast
    @url_before_type_cast ||= nil
  end

  def geo_before_type_cast
    @geo_before_type_cast ||= nil
  end

  def required_before_type_cast
    @required_before_type_cast ||= nil
  end
end

describe ATDIS::Validators do
  let(:model) { ValidatorTestModel.new }

  before do
    # Make the model valid before each example breaks one thing at a time
    model.required_before_type_cast = "something"
  end

  describe ATDIS::Validators::HttpUrlValidator do
    it "should add a plain string error when no spec_section is given" do
      model.url_before_type_cast = "not a url"
      model.url = nil
      expect(model).to_not be_valid
      expect(model.errors[:url]).to eq ["is not a valid URL"]
    end

    it "should accept an http url" do
      model.url_before_type_cast = "http://example.com"
      model.url = URI.parse("http://example.com")
      expect(model).to be_valid
    end
  end

  describe ATDIS::Validators::ArrayHttpUrlValidator do
    it "should add a plain string error when no spec_section is given" do
      model.urls = [URI.parse("http://example.com"), "not a url"]
      expect(model).to_not be_valid
      expect(model.errors[:urls]).to eq ["contains an invalid URL"]
    end

    it "should accept an array of urls" do
      model.urls = [URI.parse("http://example.com"), URI.parse("https://example.com")]
      expect(model).to be_valid
    end
  end

  describe ATDIS::Validators::ArrayValidator do
    it "should add a plain string error when no spec_section is given" do
      model.list = "not an array"
      expect(model).to_not be_valid
      expect(model.errors[:list]).to eq ["should be an array"]
    end
  end

  describe ATDIS::Validators::FilledArrayValidator do
    it "should complain about something that isn't an array" do
      model.filled_list = "not an array"
      expect(model).to_not be_valid
      expect(model.errors[:filled_list]).to eq ["should be an array"]
    end

    it "should complain about an empty array" do
      model.filled_list = []
      expect(model).to_not be_valid
      expect(model.errors[:filled_list]).to eq ["should not be an empty array"]
    end

    it "should accept a filled array" do
      model.filled_list = ["something"]
      expect(model).to be_valid
    end
  end

  describe ATDIS::Validators::GeoJsonValidator do
    it "should add a plain string error when no spec_section is given" do
      model.geo_before_type_cast = "some geojson that couldn't be parsed"
      model.geo = nil
      expect(model).to_not be_valid
      expect(model.errors[:geo]).to eq ["is not valid GeoJSON"]
    end
  end

  describe ATDIS::Validators::PresenceBeforeTypeCastValidator do
    it "should add a plain string error when no spec_section is given" do
      model.required_before_type_cast = nil
      expect(model).to_not be_valid
      expect(model.errors[:required]).to eq ["can't be blank"]
    end
  end
end
