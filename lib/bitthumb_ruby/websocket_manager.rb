require 'faye/websocket'
require 'eventmachine'
require 'json'
require 'thread'

module BitthumbRuby
  class WebSocketManager
    BITHUMB_WS_URL = 'wss://ws-api.bithumb.com/websocket/v1'
    
    def initialize(type, codes, qsize = 1000)
      @type = type
      @codes = codes
      @queue = Queue.new
      @qsize = qsize
      @alive = false
    end

    def connect()
      @alive = true
      EM.run do
        ws = Faye::WebSocket::Client.new(BITHUMB_WS_URL)

        ws.on :open do |_|
          puts 'Connected to Bithumb WebSocket'
          payload = [
            { ticket: 'test example' },
            { format: 'SIMPLE' },
          ]
          payload << {
            type: @type,
            codes: @codes,
            #isOnlySanpshot: false,
            #isOnlyRealtime: false,            
          }
          #pp payload.to_json
          # payload example: [{"ticket":"test example"},{"type":"ticker","codes":["KRW-BTC","BTC-ETH"]},{"format":"SIMPLE"}]

          ws.send(payload.to_json)
        end

        ws.on :message do |event|                    
          #puts "Raw data received: #{event.data}"
          data = JSON.parse(event.data.pack('C*'))
          #puts "data received: packed: #{data}"
          begin
            if @queue.size < @qsize
              @queue.push(data)
              puts "Data added to queue. Current size: #{@queue.size}"
            end
          rescue => e
            puts "Error parsing message: #{e.message}"
          end
          
          yield data if block_given?
        end

        ws.on :close do |event|
          puts "Disconnected with code: #{event.code}, reason: #{event.reason}"
          EM.stop
          @alive = false
        end
        
        ws.on :error do |error|
          logger.error "WebSocket error: #{error}"
        end
      end
      
      puts 'after: connect called...'
    end

    def get
      connect unless @alive
      #pp 'get: que size', @queue.size
      
      10.times do
        return @queue.pop(true) if !@queue.empty?
        #puts "Queue is empty. Retrying in 1 second..."
        sleep(1)
      end
      raise "No data available in the queue after multiple attempts."
    end

    def terminate
      @alive = false
      EM.stop if EM.reactor_running?
      
      puts "terminate called"
    end
  end
end
