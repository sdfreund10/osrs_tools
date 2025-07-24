require_relative "prices_api"
require_relative "item"

class Price
  # How in the world can I make sense of the high/low price/volume?
  # Presumable high price represents peoples sell offers, in which case high volume is related to the amount of people actively trying to buy it
  # I guess low price represtsents peoples buy offers, in which case low volume is related to the amount of people actively trying to sell it
  # Reworded, high price is the instant buy price, and low price is the instant sell price
  attr_reader :item_id, :high_price, :high_volume, :low_price, :low_volume
  def initialize(item_id, high_price, high_volume, low_price, low_volume)
    @item_id = item_id
    @high_price = high_price
    @high_volume = high_volume
    @low_price = low_price
    @low_volume = low_volume
  end

  alias_method :instant_buy_price, :high_price
  alias_method :instant_sell_price, :low_price

  def item
    @item ||= Item.find(item_id)
  end

  def high_price_formatted
    high_price.to_s.gsub(/\B(?=(...)*\b)/, ",")
  end

  def low_price_formatted
    low_price.to_s.gsub(/\B(?=(...)*\b)/, ",")
  end

  def range
    "#{low_price_formatted} - #{high_price_formatted}"
  end

  def trade_volume
    high_volume + low_volume
  end

  def margin
    return 0 if high_price.nil? || low_price.nil?

    high_price - low_price
  end

  def post_tax_margin
    return 0 if high_price.nil?

    margin - high_price * 0.02
  end

  def profit_potential
    return 0 unless post_tax_margin.positive?

    post_tax_margin * (item.trade_limit || 0)
  end

  # { "data": {
  #   "2": {
  #     "avgHighPrice":228,"highPriceVolume":1338882,"avgLowPrice":218,"lowPriceVolume":484258
  #   }
  # }
  def self.list
    PricesApi.prices.map do |item_id, item|
      new(item_id.to_i, item["avgHighPrice"], item["highPriceVolume"], item["avgLowPrice"], item["lowPriceVolume"])
    end
  end

  def self.find(item_id)
    price = PricesApi.prices[item_id.to_s]
    return nil unless price

    new(item_id, price["avgHighPrice"], price["highPriceVolume"], price["avgLowPrice"], price["lowPriceVolume"])
  end
end
