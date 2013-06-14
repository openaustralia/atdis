require 'multi_json'
require 'date'

module ATDIS
  class Application
    attr_accessor :dat_id, :description, :authority,
      :lodgement_date, :determination_date, :notification_start_date, :notification_end_date,
      :status, :more_info_url, :location

    def self.parse(text)
      interpret(MultiJson.load(text, :symbolize_keys => true))
    end

    def self.interpret(data)
      a = Application.new
      
      if data[:info]
        a.dat_id = data[:info][:dat_id]
        a.description = data[:info][:description]
        a.authority = data[:info][:authority]
        a.lodgement_date = DateTime.parse(data[:info][:lodgement_date]) if data[:info][:lodgement_date]
        a.determination_date = DateTime.parse(data[:info][:determination_date]) if data[:info][:determination_date]
        a.notification_start_date = DateTime.parse(data[:info][:notification_start_date]) if data[:info][:notification_start_date]
        a.notification_end_date = DateTime.parse(data[:info][:notification_end_date]) if data[:info][:notification_end_date]
        a.status = data[:info][:status]
      end
      a.more_info_url = data[:reference][:more_info_url] if data[:reference]
      a.location = Location.interpret(data[:location]) if data[:location]
      a
    end
  end
end
