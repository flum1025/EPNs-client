path = File.expand_path('../', __FILE__)
require File.join(path, 'lib/EPNs.rb')

api_key = "3WqjXzfcw8yUea02BNrKA154YvItsn6LipCJSukDTxoHM9hEF"
registration_id = "k1UlaD3tJHY7WvPn4OquRcZgIBhGfdiCpVmLNrxS8T0E26MwFX59KzoeyjsAQb"
EPNs.connect(api_key, registration_id) do |object|
  puts object
end
p EPNs.send([registration_id], api_key, {:test=>123})
loop do
  STDIN.gets.strip
end
#p EPNs.register(api_key)
