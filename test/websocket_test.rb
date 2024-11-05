manager = BitthumbRuby::WebSocketManager.new("ticker", ["BTC_KRW"])

# 데이터를 가져오기
3.times do
  data = manager.get
  puts data
end

# WebSocket 연결 종료
manager.terminate
