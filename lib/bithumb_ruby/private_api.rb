require 'openssl'
require 'base64'
require 'httparty'
# require 'json'
require 'uri'
require 'jwt'
require 'securerandom'

module BithumbRuby
  class PrivateApi
    include HTTParty
    base_uri 'https://api.bithumb.com/v1'
    debug_output $stdout

    # Initializes a new PrivateApi instance.
    #
    # @param conkey [String] The API key that is given by Bithumb.
    # @param seckey [String] The API secret key that is given by Bithumb.
    def initialize(conkey, seckey)
      @conkey = conkey
      @seckey = seckey
    end

    # 전체 계좌 조회
    #
    # @param params [Hash] A hash of parameters to send along with the request.
    # @return [HTTParty::Response] The response containing the account information.
    def accounts
      get_request('/accounts', {})
    end

    ########################################################
    # 주문
    ########################################################

    # 주문 가능 정보
    def balance(market)
      get_request('/orders/chance', params: { market: })
    end

    # 개별 주문 조회
    # 주문 UUID로 해당 주문의 내역을 조회합니다.
    # @param uuid [String] 주문 UUID
    def get_order(uuid)
      get_request('/orders/chance', params: { uuid: })
    end

    # 주문 리스트 조회
    # @param market	마켓 아이디	String
    # @param uuids	주문 UUID의 목록	Array
    # @param state	주문 상태
    # - wait : 체결 대기 (default)
    # - watch : 예약주문 대기
    # - done : 전체 체결 완료
    # - cancel : 주문 취소	String
    # @param states	주문 상태의 목록
    # - 일반주문(wait, done, cancel)과 자동주문(watch)은 혼합하여 조회하실 수 없습니다.	Array
    # @param page	페이지 수 (default :1)	Number
    # @param limit	개수 제한 (default: 100, limit: 100)	Number
    # @param order_by	정렬방식
    # - asc : 오름차순
    # - desc : 내림차순 (default)	String
    def list_orders(params = { market: '', uuids: [], state: 'wait', states: [], page: 1, limit: 100,
                               order_by: 'desc' })
      get_request('/orders', params: params)
    end

    # 주문 취소 접수
    # @param uuid	주문 UUID	String
    def cancel_order(uuid)
      delete_request('/order', params: { uuid: })
    end

    # 주문하기
    # @param market *	마켓 ID	String
    # @param side *	주문 종류
    # - bid : 매수
    # - ask : 매도	String
    # @param volume *	주문량 (지정가, 시장가 매도 시 필수)	NumberString
    # @param price *	주문 가격. (지정가, 시장가 매수 시 필수)
    #  ex) KRW-BTC 마켓에서 1BTC당 1,000 KRW로 거래할 경우, 값은 1000 이 된다.
    #  ex) KRW-BTC 마켓에서 1BTC당 매도 1호가가 500 KRW 인 경우, 시장가 매수 시 값을 1000으로 세팅하면 2BTC가 매수된다.
    #  (수수료가 존재하거나 매도 1호가의 수량에 따라 상이할 수 있음)	NumberString
    # @param ord_type*	주문 타입
    # - limit : 지정가 주문
    # - price : 시장가 주문(매수)
    # - market : 시장가 주문(매도)	String
    def create_order(params = { market: '', side: '', volume: '', price: '', ord_type: 'limit' })
      post_request('/orders', params: params)
    end

    private

    def post_request(endpoint, params)
      headers = {
        'Authorization': "Bearer #{create_token(params)}",
        'Content-Type': 'application/json; charset=utf-8'
      }
      response = self.class.post(endpoint, headers: headers, body: params.to_json)

      # 응답 디버깅
      puts "Response Status: #{response.code}"
      puts "Response Body: #{response.body}"

      response
    rescue JSON::ParserError => e
      puts "JSON Parsing Error: #{e.message}"
      nil
    rescue StandardError => e
      puts "Request Error: #{e.message}"
      nil
    end

    def get_request(endpoint, params)
      headers = {
        'Authorization': "Bearer #{create_token(params)}",
        'Content-Type': 'application/json; charset=utf-8'
      }
      self.class.get(endpoint, headers: headers, body: params)
    rescue JSON::ParserError => e
      puts "JSON Parsing Error: #{e.message}"
      nil
    rescue StandardError => e
      puts "Request Error: #{e.message}"
      nil
    end

    def delete_request(endpoint, params)
      headers = {
        'Authorization': "Bearer #{create_token(params)}",
        'Content-Type': 'application/json; charset=utf-8'
      }
      self.class.delete(endpoint, headers: headers, body: params)
    rescue JSON::ParserError => e
      puts "JSON Parsing Error: #{e.message}"
      nil
    rescue StandardError => e
      puts "Request Error: #{e.message}"
      nil
    end

    def create_token(params)
      payload = {
        access_key: @conkey,
        nonce: SecureRandom.uuid,
        timestamp: (Time.now.to_f * 1000).to_i
      }

      if params.any?
        query = URI.encode_www_form(params)
        query_hash = OpenSSL::HMAC.hexdigest('sha512', @seckey, query)
        payload[:query_hash] = query_hash
        payload[:query_hash_alg] = 'SHA512'
      end

      # JWT.encode의 두 번째 인자로 전달되는 키와 알고리즘을 명시적으로 지정
      JWT.encode(payload, @seckey, 'HS512')
    end
  end
end
