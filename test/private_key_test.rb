require_relative '../lib/bitthumb_ruby/private_api'
require_relative "./.env"

# BitthumbRuby 모듈의 PrivateApi 사용 예제
module PrivateApiExample
  def self.run
    # Bithumb API Key와 Secret Key
    # apikey = "YOUR_API_KEY"
    # seckey = "YOUR_SECRET_KEY"
    # apikey = "31e45ee0964ec7618f3dad5d03007c286b02ac828470ef"
    # seckey = "MmJkYWFlODFmMDZiMjM5ZDUwZWU5YjQ4Y2Q2ZGZiNGRhYjU5MDMwYjcwMjk2ZDA1YTk4NTgxN2FlNTQ3Mw=="
    apikey = BITHUMB_APIKEY
    seckey = BITHUMB_SECKEY

    # PrivateApi 인스턴스 생성
    private_api = BitthumbRuby::PrivateApi.new(apikey, seckey)

    # 1. 계정 정보 조회 예제
    puts "1. Account Information:"
    account_info = private_api.accounts
    puts account_info

    # 2. 잔고 조회 예제: 특정 암호화폐(BTC)의 잔고를 가져옵니다.
    # puts "\n2. Balance for BTC:"
    # balance_info = private_api.balance(currency: "BTC")
    # puts balance_info

    # 3. 매수 주문 예제: BTC를 KRW로 매수하는 한정가 주문
    # puts "\n3. Place a Buy Limit Order:"
    # order_info = private_api.place(type: "bid", order_currency: "BTC", payment_currency: "KRW", units: 0.01, price: 30000000)
    # puts order_info

    # # 4. 미체결 주문 조회 예제
    # puts "\n4. Outstanding Orders:"
    # outstanding_orders = private_api.orders(type: "bid", order_currency: "BTC", payment_currency: "KRW")
    # puts outstanding_orders

    # # 5. 주문 취소 예제
    # puts "\n5. Cancel an Order:"
    # if order_info && order_info["order_id"]
    #   cancel_info = private_api.cancel(type: "bid", order_currency: "BTC", payment_currency: "KRW", order_id: order_info["order_id"])
    #   puts cancel_info
    # else
    #   puts "No order to cancel"
    # end
  end
end

# 실행
PrivateApiExample.run
