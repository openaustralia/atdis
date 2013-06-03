require 'multi_json'

module ATDIS
  class Application
    attr_accessor :dat_id, :description, :authority, :status, :more_info_url

    def self.parse(text)
      data = MultiJson.load(text, :symbolize_keys => true)
      a = Application.new
      a.dat_id = data[:info][:dat_id]
      a.description = data[:info][:description]
      a.authority = data[:info][:authority]
      a.status = data[:info][:status]
      a.more_info_url = data[:reference][:more_info_url]
      a
    end
  end
end
