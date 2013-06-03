require 'multi_json'

module ATDIS
  class Application
    attr_accessor :dat_id

    def self.parse(text)
      data = MultiJson.load(text, :symbolize_keys => true)
      a = Application.new
      a.dat_id = data[:info][:dat_id]
      a
    end
  end
end
