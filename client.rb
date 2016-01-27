path = File.expand_path('../', __FILE__)
require File.join(path, 'lib/EPNs.rb')

url = "http://localhost:3000/weset/websocket/connect"
api_key = ""
registration_id = ""
EPNs.connect(url, api_key, registration_id) do |object|
  puts object
end
loop do
  STDIN.gets.strip
end