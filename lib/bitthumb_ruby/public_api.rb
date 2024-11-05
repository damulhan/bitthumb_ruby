require 'httparty'

module BitthumbRuby
  class PublicApi
    include HTTParty
    base_uri 'https://api.bithumb.com'

    # Retrieves the current ticker information for a specified order currency and payment currency.
    #
    # @param order_currency [String] The currency to order.
    # @param payment_currency [String] The currency to pay, default is "KRW".
    # @return [HTTParty::Response] The response containing ticker information.
    def ticker(order_currency, payment_currency = 'KRW')
      self.class.get("/public/ticker/#{order_currency}_#{payment_currency}")
    end

    # Retrieves the transaction history for a specified order currency and payment currency.
    #
    # @param order_currency [String] The currency for the order.
    # @param payment_currency [String] The currency to pay, default is "KRW".
    # @param limit [Integer] The number of transactions to retrieve, default is 20.
    # @return [HTTParty::Response] The response containing transaction history.
    def transaction_history(order_currency, payment_currency = 'KRW', limit = 20)
      self.class.get("/public/transaction_history/#{order_currency}_#{payment_currency}", query: { count: limit })
    end

    # Retrieves the orderbook information for a specified order currency and payment currency.
    #
    # @param order_currency [String] The currency for the order.
    # @param payment_currency [String] The currency to pay, default is "KRW".
    # @param limit [Integer] The number of orders to retrieve, default is 5.
    # @return [HTTParty::Response] The response containing orderbook information.
    def orderbook(order_currency, payment_currency = 'KRW', limit = 5)
      self.class.get("/public/orderbook/#{order_currency}_#{payment_currency}", query: { count: limit })
    end

    # Retrieves the BTCI (Bithumb Technical Index) for all of the traded
    # currencies.
    #
    # @return [HTTParty::Response] The response containing the BTI.
    def btci
      self.class.get('/public/btci')
    end

    # Retrieves the candlestick chart data for a specified order currency and
    # payment currency.
    #
    # @param order_currency [String] The currency for the order.
    # @param payment_currency [String] The currency to pay, default is "KRW".
    # @param chart_intervals [String] The interval of the chart, default is "24h".
    # @return [HTTParty::Response] The response containing the candlestick chart data.
    def candlestick(order_currency, payment_currency = 'KRW', chart_intervals = '24h')
      self.class.get("/public/candlestick/#{order_currency}_#{payment_currency}/#{chart_intervals}")
    end
  end
end
