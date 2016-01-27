require 'websocket-client-simple'
require 'open-uri'
require 'json'

module EPNs
  class EPNsError < Exception; end

  def self.connect(url, api_key, registration_id, &blk)
    ::EPNs::Client.new(Connection.builder(url, api_key, registration_id), blk)
  end

  class Connection
    def self.builder(url, api_key, reg_id)
      token = open("#{url}?api_key=#{api_key}&registration_id=#{reg_id}")
      json = JSON.parse(token.read)
    end
  end

  class Client
    def initialize(opt, blk)
      connect("#{opt['data']['url']}:#{opt['data']['port']}", opt['data']['req_body'], blk)
    end

    def connect(url, req_body, blk)
      ws = WebSocket::Client::Simple.connect url

      ws.on :message do |msg|
        #puts msg.data
        blk.call(msg.data)
      end

      ws.on :open do
        ws.send req_body.to_json
      end

      ws.on :close do |e|
      end

      ws.on :error do |e|
      end
    end
  end
end

