require 'multi_json'
require 'date'

module ATDIS
  Application = Struct.new(:dat_id, :last_modified_date, :description, :authority,
      :lodgement_date, :determination_date, :status, :notification_start_date, :notification_end_date,
      :officer, :estimated_cost, :more_info_url, :comments_url, :location) do

    def self.parse(text)
      interpret(MultiJson.load(text, :symbolize_keys => true))
    end

    def self.interpret(data)
      if data[:info]
        dat_id = data[:info][:dat_id]
        last_modified_date = DateTime.parse(data[:info][:last_modified_date]) if data[:info][:last_modified_date]
        description = data[:info][:description]
        authority = data[:info][:authority]
        lodgement_date = DateTime.parse(data[:info][:lodgement_date]) if data[:info][:lodgement_date]
        determination_date = DateTime.parse(data[:info][:determination_date]) if data[:info][:determination_date]
        status = data[:info][:status]
        notification_start_date = DateTime.parse(data[:info][:notification_start_date]) if data[:info][:notification_start_date]
        notification_end_date = DateTime.parse(data[:info][:notification_end_date]) if data[:info][:notification_end_date]
        officer = data[:info][:officer]
        estimated_cost = data[:info][:estimated_cost]
      end
      if data[:reference]
        more_info_url = URI.parse(data[:reference][:more_info_url]) if data[:reference][:more_info_url]
        comments_url = URI.parse(data[:reference][:comments_url]) if data[:reference][:comments_url]
      end
      location = Location.interpret(data[:location]) if data[:location]

      Application.new(dat_id, last_modified_date, description, authority,
        lodgement_date, determination_date, status, notification_start_date, notification_end_date,
        officer, estimated_cost, more_info_url, comments_url, location)
    end
  end
end
