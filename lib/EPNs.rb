require 'websocket-client-simple'
require 'open-uri'
require 'json'

$host = "http://localhost:3000"
$ssl = false

module EPNs
  class EPNsError < StandardError; end

  def self.connect(api_key, registration_id, &blk)
    ::EPNs::Client.new(Connection.builder(api_key, registration_id), blk)
  end
  
  def self.register(api_key)
    ::EPNs::Connection.register(api_key)
  end
  
  def self.send(ids, api_key, options={})
    ::EPNs::Connection.send_notification(ids, api_key, options)
  end

  class Connection
    def self.builder(api_key, reg_id)
      res = open(URI.parse("#{File.join($host, 'weset/websocket/connect')}?api_key=#{api_key}&registration_id=#{reg_id}"))
      json = JSON.parse(res.read)
      error?(json)
      return json
    end
    
    def self.register(api_key)
      res = open(URI.parse("#{File.join($host, 'weset/websocket/regist')}?api_key=#{api_key}"))
      json = JSON.parse(res.read)
      error?(json)
      return json['data']['registration_id']
    end
    
    def self.send_notification(ids, api_key, options)
      res = open(URI.parse("#{File.join($host, 'weset/websocket/send_notification')}?api_key=#{api_key}&registration_ids=#{ids.join(",")}&options=#{options.to_json}"))
      json = JSON.parse(res.read)
      error?(json)
      return json
    end
    
    def self.error?(json)
      return if json['error'].nil?
      raise EPNsError, "#{json['error']['message']}:#{json['error']['code']}"
    end
    
    def self.post(params, url)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = $ssl
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(params)
      response = nil
      http.start do |h|
        response = h.request(request).body
      end
      json = JSON.parse(response)
      log(URL + url, params ,json)
      return json
    end
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