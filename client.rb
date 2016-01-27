require 'websocket-client-simple'
require 'open-uri'
require 'json'

token = open("http://localhost:3000/weset/websocket/connect?api_key=*******************&registration_id=******************")
json = JSON.parse(token.read)
p "#{json['data']['url']}:#{json['data']['port']}"

ws = WebSocket::Client::Simple.connect "#{json['data']['url']}:#{json['data']['port']}"#'ws://localhost:11451'

ws.on :message do |msg|
  puts msg.data
end

ws.on :open do
  ws.send json['data']['req_body'].to_json
end

ws.on :close do |e|
  p e
  exit 1
end

ws.on :error do |e|
  p e
end

loop do
  ws.send STDIN.gets.strip
end