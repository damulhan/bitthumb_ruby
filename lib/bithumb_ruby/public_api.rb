require 'httparty'
require 'time'

module BithumbRuby
  class PublicApi
    include HTTParty

    base_uri 'https://api.bithumb.com/v1'

    def market_all(is_details: false)
      self.class.get('/market/all', query: { isDetails: is_details })
    end

    # @param market	[String] 마켓 코드 (ex. KRW-BTC)
    # @param to [String]	마지막 캔들 시각 (exclusive).  ISO8061 포맷 (yyyy-MM-dd'T'HH:mm:ss'Z' or yyyy-MM-dd HH:mm:ss). 기본적으로 KST 기준 시간이며 비워서 요청시 가장 최근 캔들
    # @param count [Integer] 캔들 개수(최대 200개까지 요청 가능)
    # @param convertingPriceUnit [String] 종가 환산 화폐 단위 (생략할 수 있으며 KRW로 입력한 경우 원화 환산 가격으로 반환됨)
    def candles(market, candle_type: 'minutes', to: nil, count: 200, unit: 1, converting_price_unit: 'KRW')
      raise(ArgumentError, 'Count must be less than or equal to 200') if count > 200

      to = Time.now.strftime('%Y-%m-%dT%H:%M:%S') if to.nil?
      #to = Time.now.iso8601 if to.nil?
      
      case candle_type
      when 'minutes'
        units = [1, 3, 5, 10, 15, 30, 60, 240]
        raise ArgumentError, "Invalid unit. Valid units are #{units.join(', ')}" unless units.include?(unit)

        self.class.get("/candles/minutes/#{unit}", query: {
                         market:,
                         to:,
                         count:
                       })

      when 'days'
        self.class.get('/candles/days', query: {
                         market:,
                         to:,
                         count:,
                         convertingPriceUnit: converting_price_unit
                       })

      when 'weeks'
        self.class.get('/candles/weeks', query: {
                         market:,
                         to:,
                         count:
                       })

      when 'months'
        self.class.get('/candles/months', query: {
                         market:,
                         to:,
                         count:
                       })

      end
    end

    # @param market string required 마켓 코드 (ex. KRW-BTC)
    # @param to string 마지막 체결 시각. 형식 : [HHmmss 또는 HH:mm:ss]. 비워서 요청시 가장 최근 데이터
    # @param count int32 Defaults to 1 체결 개수
    # @param cursor string 페이지네이션 커서 (sequentialId)
    # @param daysAgo int32 최근 체결 날짜 기준 7일 이내의 이전 데이터 조회 가능. 비워서 요청 시 가장 최근 체결 날짜 반환. (범위: 1 ~ 7)
    def trade_ticks(market, to: nil, count: 1, cursor: '', days_ago: 7)
      self.class.get('/trades/ticks', query: { market:, to:, count:, cursor:, daysAgo: days_ago})
    end

    # @param markets [array of strings] required 마켓 코드 목록 (ex. KRW-BTC,BTC-ETH)
    def ticker(markets)
      self.class.get('/ticker', query: { markets: })
    end

    # 호가 정보 조회
    # @param markets [array of strings] required 마켓 코드 목록 (ex. KRW-BTC,BTC-ETH)
    def orderbook(markets)
      self.class.get("/orderbook/#{markets}")
    end

    # 경보중인 마켓-코인 목록 조회
    def virtual_asset_warning
      self.class.get('/market/virtual_asset_warning')
    end
    # market	빗썸에서 제공중인 시장 정보	String
    # warning_type	경보 유형
    # - PRICE_SUDDEN_FLUCTUATION: 가격 급등락
    # - TRADING_VOLUME_SUDDEN_FLUCTUATION: 거래량 급등
    # - DEPOSIT_AMOUNT_SUDDEN_FLUCTUATION: 입금량 급등
    # - PRICE_DIFFERENCE_HIGH: 가격 차이
    # - SPECIFIC_ACCOUNT_HIGH_TRANSACTION: 소수계좌 거래 집중
    # - EXCHANGE_TRADING_CONCENTRATION: 거래소 거래 집중	String
    # end_date	가상 자산 경보 종료일시(KST 기준)
    #   포맷: yyyy-MM-dd HH:mm:ss	String
  end
end
