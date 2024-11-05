require 'openssl'
require 'base64'
require 'httparty'

module BitthumbRuby
  class PrivateApi
    include HTTParty
    base_uri 'https://api.bithumb.com'

    # Initializes a new PrivateApi instance.
    #
    # @param conkey [String] The API key that is given by Bithumb.
    # @param seckey [String] The API secret key that is given by Bithumb.
    def initialize(conkey, seckey)
      @conkey = conkey
      @seckey = seckey
    end

    # Retrieves information about the account associated with the API key.
    #
    # @param params [Hash] A hash of parameters to send along with the request.
    # @return [HTTParty::Response] The response containing the account information.
    def account(params = {})
      post_request('/info/account', params)
    end

    # Retrieves the current balance of the account associated with the API key.
    #
    # @param params [Hash] A hash of parameters to send along with the request.
    # @return [HTTParty::Response] The response containing the account balance.
    def balance(params = {})
      post_request('/info/balance', params)
    end

    # Places an order to Bithumb.
    #
    # @param params [Hash] A hash of parameters to send along with the request.
    # @option params [String] :order_currency The currency to order.
    # @option params [String] :payment_currency The currency to pay, default is "KRW".
    # @option params [String] :units The units of the currency to order.
    # @option params [String] :price The price to order at.
    # @option params [String] :type The type of the order, either "bid" or "ask".
    # @return [HTTParty::Response] The response containing the result of the order.
    def place(params = {})
      post_request('/trade/place', params)
    end

    private

    # Performs a POST request to the specified endpoint with the given parameters
    # and authentication information.
    #
    # @param endpoint [String] The endpoint to make the request to.
    # @param params [Hash] A hash of parameters to send along with the request.
    # @return [HTTParty::Response] The response from the server.
    def post_request(endpoint, params)
      nonce = (Time.now.to_f * 1000).to_i.to_s
      signature = create_signature(endpoint, params, nonce)
      headers = {
        'Api-Key' => @conkey,
        'Api-Sign' => signature,
        'Api-Nonce' => nonce
      }
      self.class.post(endpoint, headers: headers, body: params)
    end

    def create_signature(endpoint, params, nonce)
      data = "#{endpoint}#{nonce}#{URI.encode_www_form(params)}"
      hmac = OpenSSL::HMAC.digest('sha512', @seckey, data)
      Base64.strict_encode64(hmac)
    end
  end
end
