require 'technical-analysis'
require 'json'
require 'byebug'
require 'thread'

require_relative '../lib/bithumb_ruby/public_api'

class MovingAverageStrategy
  def initialize(api, market: 'KRW-BTC', candle_unit: 10, short_window: 5, long_window: 20, rsi_period: 14, stop_loss: 0.05, take_profit: 0.10)
    @api = api
    @market = market
    @candle_unit = candle_unit
    @short_window = short_window
    @long_window = long_window
    @rsi_period = rsi_period
    @stop_loss = stop_loss # 손절매 비율 (예: 0.05는 5% 손절)
    @take_profit = take_profit # 익절 비율 (예: 0.10은 10% 익절)
    @position = nil # 현재 포지션 (nil, :buy, :sell)
    @buy_price = nil # 매수 가격 기록

    # 큐 초기화: 최대 크기를 짧은 기간(최소 필요 데이터 크기)보다 커야 합니다.
    @candle_queue = Queue.new
    @max_queue_size = [@short_window, @long_window, @rsi_period].max + 50  # 50을 추가하여 여유 공간 제공
  end

  def fetch_and_store_candle_data
    # 서버에서 데이터를 가져옴
    response = @api.candles(@market, candle_type: 'minutes', unit: @candle_unit, count: [@short_window, @long_window, @rsi_period].max)
    return [] unless response.success?

    # 응답 데이터를 큐에 추가
    candles = JSON.parse(response.body).map do |candle|
      {
        date_time: candle['timestamp'],
        date_time_str: candle['candle_date_time_kst'],
        close: candle['trade_price'].to_f,
      }
    end.reverse

    candles.each { |candle| @candle_queue.push(candle) }

    # 큐의 크기를 제한
    if @candle_queue.size > @max_queue_size
      # 최대 크기를 넘으면 가장 오래된 데이터를 제거
      @candle_queue.pop
    end
  end

  def get_last_candles(count)
    # 큐에서 마지막 N개의 데이터를 가져옴
    candles = []
    count.times do
      break if @candle_queue.empty?
      candles.unshift(@candle_queue.pop)
    end
    candles
  end

  def calculate_moving_averages(prices)
    simple_moving_average = TechnicalAnalysis::Indicator.find('sma')

    short_ma = simple_moving_average.calculate(prices, period: @short_window, price_key: :close)
    long_ma = simple_moving_average.calculate(prices, period: @long_window, price_key: :close)

    [short_ma, long_ma]
  end

  def calculate_rsi(prices)
    rsi_indicator = TechnicalAnalysis::Indicator.find('rsi')
    rsi = rsi_indicator.calculate(prices, period: @rsi_period, price_key: :close)
    rsi
  end

  def calculate_macd(prices)
    macd_indicator = TechnicalAnalysis::Indicator.find('macd')
    macd = macd_indicator.calculate(prices, price_key: :close)
    macd
  end

  def evaluate_strategy
    prices = fetch_and_store_candle_data

    # 큐에서 마지막 데이터를 가져옵니다. (필요한 만큼의 개수)
    candles = get_last_candles([@short_window, @long_window, @rsi_period].max)
    return if candles.size < @rsi_period # 충분한 데이터가 없으면 실행하지 않음

    short_ma, long_ma = calculate_moving_averages(candles)
    rsi = calculate_rsi(candles)
    macd = calculate_macd(candles)

    puts "Short MA: #{short_ma.last.sma}, Long MA: #{long_ma.last.sma}"
    puts "RSI: #{rsi.last.rsi}, MACD Line: #{macd.last.macd}, Signal Line: #{macd.last.signal}"

    # 매수 조건: 이동 평균 골든 크로스 + RSI 과매도 + MACD 상향 교차
    if @position.nil? && short_ma.last.sma > long_ma.last.sma && rsi.last.rsi < 30 && macd.last.macd > macd.last.signal
      execute_buy_order(prices.last.close)
    # 매도 조건: 이동 평균 데드 크로스 + RSI 과매도 + MACD 하향 교차
    elsif @position == :buy && (short_ma.last.sma < long_ma.last.sma || rsi.last.rsi > 70 || macd.last.macd < macd.last.signal || check_stop_loss(prices.last.close) || check_take_profit(prices.last.close))
      execute_sell_order(prices.last.close)
    end
  end

  def execute_buy_order(current_price)
    puts "Buy signal detected! Executing buy order..."
    @position = :buy
    @buy_price = current_price
    # 매수 로직 추가 (API로 주문 실행)
  end

  def execute_sell_order(current_price)
    puts "Sell signal detected! Executing sell order..."
    @position = :sell
    # 매도 로직 추가 (API로 주문 실행)
  end

  def check_stop_loss(current_price)
    return false if @buy_price.nil?

    # 손절매 조건: 매수 가격에서 지정한 비율 이상 하락
    if current_price <= @buy_price * (1 - @stop_loss)
      puts "Stop loss triggered! Selling at #{current_price}."
      true
    else
      false
    end
  end

  def check_take_profit(current_price)
    return false if @buy_price.nil?

    # 익절 조건: 매수 가격에서 지정한 비율 이상 상승
    if current_price >= @buy_price * (1 + @take_profit)
      puts "Take profit triggered! Selling at #{current_price}."
      true
    else
      false
    end
  end

  def run
    loop do
      evaluate_strategy
      sleep 60 # 1분 간격으로 실행
    end
  end
end

# 실행
api = BithumbRuby::PublicApi.new
strategy = MovingAverageStrategy.new(api)
strategy.run
