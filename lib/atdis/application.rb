require 'multi_json'

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
      a.dat_id = data[:info][:dat_id]
      a.description = data[:info][:description]
      a.authority = data[:info][:authority]
      a.lodgement_date = DateTime.parse(data[:info][:lodgement_date])
      a.determination_date = DateTime.parse(data[:info][:determination_date])
      a.notification_start_date = DateTime.parse(data[:info][:notification_start_date])
      a.notification_end_date = DateTime.parse(data[:info][:notification_end_date])
      a.status = data[:info][:status]
      a.more_info_url = data[:reference][:more_info_url]
      a.location = Location.interpret(data[:location])
      a
    end
  end
end
