require_relative '../lib/bitthumb_ruby/websocket_manager'

puts "starting..."

manager = BitthumbRuby::WebSocketManager.new("ticker", ["KRW-BTC"])

thread = Thread.new do 
  manager.connect do
    data = manager.get
    if data
      puts "=" * 50
      puts data
    else
      puts "No data received in this iteration."
    end
    
  end 
end

#loop do 
  # WebSocket 연결 종료
  #manager.terminate
#end

thread.join 

