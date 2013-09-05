require 'multi_json'

module ATDIS
  class Application < Model
    casting_attributes :last_modified_date => DateTime,
      :lodgement_date => DateTime,
      :determination_date => DateTime,
      :notification_start_date => DateTime,
      :notification_end_date => DateTime,
      :more_info_url => URI,
      :comments_url => URI,
      :description => String,
      :dat_id => String,
      :authority => String,
      :status => String,
      :officer => String,
      :estimated_cost => String,
      :location => Location

    attr_accessor :events, :documents, :people

    validates :dat_id, :description, :authority, :status, :presence => true
    validates :last_modified_date, :lodgement_date, :determination_date, :presence_before_type_cast => true, :date_time => true
    validates :more_info_url, :presence_before_type_cast => true, :url => true
    # Optional
    validates :notification_start_date, :notification_end_date, :date_time => true

    # TODO Validate associated like locations, events, documents, people
    # TODO Add support for "extended" json parameters

    # How the json parameters map to our attributes
    field_mappings :info => {
        :dat_id => :dat_id,
        :last_modified_date => :last_modified_date,
        :description => :description,
        :authority => :authority,
        :lodgement_date => :lodgement_date,
        :determination_date => :determination_date,
        :status => :status,
        :notification_start_date => :notification_start_date,
        :notification_end_date => :notification_end_date,
        :officer => :officer,
        :estimated_cost => :estimated_cost
      },
      :reference => {
        :more_info_url => :more_info_url,
        :comments_url => :comments_url
      },
      :location => :location,
      :events => :events,
      :documents => :documents,
      :people => :people
  
    def events=(v)
      @events = v.map{|e| Event.interpret(e)} if v
    end

    def documents=(v)
      @documents = v.map{|d| Document.interpret(d)} if v
    end

    def people=(v)
      @people = v.map{|p| Person.interpret(p)} if v
    end
  end
end
