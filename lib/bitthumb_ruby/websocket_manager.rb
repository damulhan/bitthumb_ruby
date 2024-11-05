require 'faye/websocket'
require 'eventmachine'
require 'json'
require 'thread'

module BitthumbRuby
  class WebSocketManager
    BITHUMB_WS_URL = 'wss://pubwss.bithumb.com/pub/ws'

    # Initializes a new WebSocketManager instance.
    #
    # @param type [String] The type of the WebSocket message to subscribe.
    # @param symbols [Array<String>] The symbols to subscribe. Each symbol should be in the form of "BTC_KRW" or "ETH_KRW".
    # @param tick_types [Array<String>] The tick types to subscribe. Each tick type should be in the form of "1H" or "1D". Default is ["1H"].
    # @param qsize [Integer] The size of the internal queue. The queue is bounded so that it will not consume too much memory. If the queue is full, it will drop the oldest message. Default is 1000.
    def initialize(type, symbols, tick_types = ['1H'], _qsize = 1000)
      @type = type
      @symbols = symbols
      @tick_types = tick_types
      @queue = Queue.new
      @alive = false
    end

    # Connects to Bithumb WebSocket and subscribes to given type and symbols.
    #
    # When connected, it will receive messages from Bithumb WebSocket and
    # stores them in an internal queue. The queue is bounded so that it will
    # not consume too much memory. If the queue is full, it will drop the
    # oldest message.
    #
    # When disconnected, it will stop the EventMachine loop and set @alive
    # to false.
    def connect
      @alive = true
      EM.run do
        ws = Faye::WebSocket::Client.new(BITHUMB_WS_URL)

        ws.on :open do |_|
          puts 'Connected to Bithumb WebSocket'
          subscribe_message = {
            type: @type,
            symbols: @symbols,
            tickTypes: @tick_types
          }
          ws.send(subscribe_message.to_json)
        end

        ws.on :message do |event|
          data = JSON.parse(event.data)
          @queue.push(data) if @queue.size < qsize
        end

        ws.on :close do |event|
          puts "Disconnected with code: #{event.code}, reason: #{event.reason}"
          EM.stop
          @alive = false
        end
      end
    end

    # Retrieves a message from the internal queue. If the queue is empty,
    # it will connect to Bithumb WebSocket and subscribe to the given type
    # and symbols, and then retrieve the first message from the queue.
    #
    # @return [Hash] The message from the internal queue.
    def get
      connect unless @alive
      @queue.pop
    end

    # Terminates the WebSocket connection and stops the EventMachine reactor if it is running.
    #
    # Sets the @alive flag to false to indicate that the WebSocket connection is no longer active.
    # If the EventMachine reactor is currently running, it will be stopped.
    def terminate
      @alive = false
      EM.stop if EM.reactor_running?
    end
  end
end
