require "httparty"
require "singleton"
require "json"

class PricesApi
  include Singleton

  ITEM_MAPPING_URL = "https://prices.runescape.wiki/api/v1/osrs/mapping"
  FIVE_MINUTE_PRICES = "https://prices.runescape.wiki/api/v1/osrs/5m"
  ONE_HOUR_PRICES = "https://prices.runescape.wiki/api/v1/osrs/1h"

  attr_reader :offline
  def initialize(offline = false)
    @last_fetch_times = {
      items: nil,
      five_min: nil,
      one_hour: nil
    }
    @offline = false
  end

  def items
    return @items unless @last_fetch_times[:items].nil? || @last_fetch_times[:items] < (Time.now - 60 * 60)

    @last_fetch_times[:items] = Time.now
    @items = if offline
      offline_file = File.dirname(__FILE__) + "/items.json"
      JSON.parse(File.read(offline_file))
    else
      puts "fetching items"
      HTTParty.get(ITEM_MAPPING_URL)
    end
  end

  def five_minute_prices
    return @five_minute_prices unless @last_fetch_times[:five_min].nil? || @last_fetch_times[:five_min] < (Time.now - 5 * 60)

    @last_fetch_times[:five_min] = Time.now

    @five_minute_prices = if offline
      offline_file = File.dirname(__FILE__) + "/prices.json"
      JSON.parse(File.read(offline_file))
    else
      puts "fetching prices"
      HTTParty.get(FIVE_MINUTE_PRICES)["data"]
    end
  end

  def last_cache_refresh(type)
    @last_fetch_times[type]
  end

  # { "data": {
  #   "2": {
  #     "avgHighPrice":228,"highPriceVolume":1338882,"avgLowPrice":218,"lowPriceVolume":484258
  #   }
  # }
  def prices
    five_minute_prices
  end

  def one_hour_prices
    return @one_hour_prices unless @last_fetch_times[:one_hour].nil? || @last_fetch_times[:one_hour] < (Time.now - 60 * 60)

    @last_fetch_times[:one_hour] = Time.now

    @one_hour_prices = if offline
      offline_file = File.dirname(__FILE__) + "/one_hour_prices.json"
      JSON.parse(File.read(offline_file))
    else
      puts "fetching one hour prices"
      HTTParty.get(ONE_HOUR_PRICES)["data"]
    end
  end

  def self.prices_refreshed_at
    instance.last_cache_refresh(:five_min)
  end

  def self.items_refreshed_at
    instance.last_cache_refresh(:items)
  end

  def self.items
    instance.items
  end

  def self.prices
    instance.prices
  end

  def self.five_minute_prices
    instance.five_minute_prices
  end

  def self.one_hour_prices
    instance.one_hour_prices
  end

  def self.offline?
    instance.offline
  end

  def self.offline!
    instance.instance_variable_set(:@offline, true)
  end

  def self.online!
    instance.instance_variable_set(:@offline, false)
  end
end
