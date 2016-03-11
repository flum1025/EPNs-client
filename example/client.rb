require 'epns_client'

#$host = "http://localhost:3000"

#api_keyの指定
api_key = "3WqjXzfcw8yUea02BNrKA154YvItsn6LipCJSukDTxoHM9hEF" #ダミー

#registration_idの指定 EpnsClient.sendする場合は必須
#registration_id = "HkKTJrZCLlGFYMcAqtR7fg2u5dUnz1wBIO6vQN4xm9i0bey38PaDXESVsopjhW" #ダミー

#新しいregistration_idの取得
registration_id =  EpnsClient.register(api_key)

#サーバー側から新しいpushがあった場合にブロック内が実行される
EpnsClient.connect(api_key, registration_id) do |object|
  puts object
end

#クライアントにデータをpushする
sleep(3) #connect直後だとsendしてもfailureになる
p EpnsClient.send([registration_id], api_key, {:test=>123})
  
#Threadで動いているので終わらない処理を書かないと終了する
loop do
  STDIN.gets.strip
end

