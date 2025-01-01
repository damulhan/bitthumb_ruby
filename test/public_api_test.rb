require_relative '../lib/bitthumb_ruby/public_api'

# BitthumbRuby 모듈의 PublicApi 사용 예제
module Example
  def self.run
    # PublicApi 인스턴스 생성
    public_api = BitthumbRuby::PublicApi.new

    # Ticker API 예제: 특정 암호화폐의 현재 시세를 가져옵니다.
    puts '1. Ticker Data for BTC_KRW:'
    ticker_data = public_api.ticker('KRW-BTC')
    puts ticker_data

    # Transaction History API 예제: 최근 거래 기록을 가져옵니다.
    puts "\n2. Recent Transaction History for BTC_KRW:"
    transaction_data = public_api.trade_ticks('KRW-BTC')
    puts transaction_data

    # Orderbook API 예제: 현재 호가 정보를 가져옵니다.
    puts "\n3. Orderbook for BTC_KRW:"
    orderbook_data = public_api.orderbook('KRW-BTC')
    puts orderbook_data

    # BTCI API 예제: Bithumb Crypto Index(BTCI) 정보를 가져옵니다.
    # puts "\n4. BTCI Data:"
    # btci_data = public_api.btci
    # puts btci_data

    # Candlestick API 예제: 특정 차트 간격의 캔들스틱 데이터를 가져옵니다.
    puts "\n5. Candlestick Data for BTC_KRW (24h intervals):"
    candlestick_data = public_api.candles('KRW-BTC', to: nil, count: 1)
    puts candlestick_data
  end
end

# 실행
Example.run
