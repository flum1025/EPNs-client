require "epns_client/version"

require 'websocket-client-simple'
require 'open-uri'
require 'json'
require 'net/http'

$host = "http://epns.flum.pw"
$ssl = false

module EpnsClient
  class EpnsClientError < StandardError; end

  def self.connect(api_key, registration_id, &blk)
    ::EpnsClient::Client.new(Connection.builder(api_key, registration_id), blk)
  end
  
  def self.register(api_key)
    ::EpnsClient::Connection.register(api_key)
  end
  
  def self.send(ids, api_key, options={})
    ::EpnsClient::Connection.send_notification(ids, api_key, options)
  end

  class Connection
    def self.builder(api_key, reg_id)
      params = Hash.new
      params.store('api_key', api_key)
      params.store('registration_id', reg_id)
      json = post(params, File.join($host, 'weset/websocket/connect'))
      error?(json)
      return json
    end
    
    def self.register(api_key)
      params = Hash.new
      params.store('api_key', api_key)
      json = post(params, File.join($host, 'weset/websocket/regist'))
      error?(json)
      return json['data']['registration_id']
    end
    
    def self.send_notification(ids, api_key, options)
      params = Hash.new
      params.store('api_key', api_key)
      params.store('registration_ids', ids)
      params.store('options', options.to_json)
      json = post(params, File.join($host, 'weset/websocket/send_notification'))
      error?(json)
      return json
    end
    
    def self.error?(json)
      return if json['error'].nil?
      raise EpnsClientError, "#{json['error']['message']}:#{json['error']['code']}"
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
      return json
    end
  end

  class Client
    def initialize(opt, blk)
      connect("#{opt['data']['url']}:#{opt['data']['port']}", opt['data']['req_body'], blk)
    end

    def connect(url, req_body, blk)
      ws = WebSocket::Client::Simple.connect url

      ws.on :message do |msg|
        blk.call(msg.data)
      end

      ws.on :open do
        ws.send req_body.to_json
      end

      ws.on :close do |e|
        puts e
      end

      ws.on :error do |e|
        puts e
      end
    end
  end
end